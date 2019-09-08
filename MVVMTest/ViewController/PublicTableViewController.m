//
//  PublicTableViewController.m
//  MVVMTest
//
//  Created by 李泽鲁 on 15/1/8.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import "PublicTableViewController.h"
#import "PublicWeiboViewModel.h"
#import "PublicCell.h"
#import "PublicDetailViewController.h"

@interface PublicTableViewController ()

@property (copy, nonatomic) NSArray<PublicCellViewModel *> *publicModelArray;
@property (strong, nonatomic) PublicWeiboViewModel *publicViewModel;
@end

@implementation PublicTableViewController
#pragma mark - lift cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViewModel];
}

#pragma mark - config

/**
 创建ViewModel
 */
- (void)createViewModel {
    self.publicViewModel = [[PublicWeiboViewModel alloc] init];
    __weak typeof(self) weak_self = self;
    [self.publicViewModel setBlockWithReturnBlock:^(id returnValue, WeboRequsetType requestType) {
        [weak_self handelRequestData:returnValue reqeustType:requestType];
    } WithErrorBlock:^(id errorCode) {
        [SVProgressHUD dismiss];
    } WithFailureBlock:^{
        [SVProgressHUD dismiss];
    }];

    
    [self.publicViewModel fetchPublicWeiBo];
    [SVProgressHUD showWithStatus:@"正在获取用户信息……" maskType:SVProgressHUDMaskTypeBlack];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.publicViewModel otherDataFetch];
    });
    
}

-(void)handelRequestData:(id)returnValue reqeustType:(WeboRequsetType)type {
    [SVProgressHUD dismiss];
    
    switch (type) {
        case ListRequest:
            _publicModelArray = returnValue;
            [self.tableView reloadData];
            break;
        
        case Other:
            //处理其他数据返回的情况，一个VC对应一个VM, 一个VM可能对应多个数据处理结果
            [SVProgressHUD showSuccessWithStatus:returnValue];
            break;
            
        default:
            break;
    }
   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _publicModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PublicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCell" forIndexPath:indexPath];
    [cell bindCellViewModel:_publicModelArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PublicCellViewModel *cellViewModel = _publicModelArray[indexPath.row];
    return cellViewModel.cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self weiboDetailWithPublicModel:_publicModelArray[indexPath.row]];
}

/**
 跳转到详情页面，如需网路请求的，可在此方法中添加相应的网络请求
 
 @param publicModel 传到下一个页面的值
 @param superController 上一个VC
 */
- (void)weiboDetailWithPublicModel:(PublicCellViewModel *) cellViewModel
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PublicDetailViewController *detailController = [storyboard instantiateViewControllerWithIdentifier:@"PublicDetailViewController"];
    detailController.cellViewModel = cellViewModel;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)dealloc
{
    DDLog(@"PublicTableViewController - 释放");
}


@end
