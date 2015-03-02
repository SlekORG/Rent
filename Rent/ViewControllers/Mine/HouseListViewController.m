//
//  HouseListViewController.m
//  Rent
//
//  Created by KID on 15/3/2.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "HouseListViewController.h"
#import "REngine.h"
#import "XEProgressHUD.h"
#import "RHouseInfo.h"
#import "HouseDetailViewController.h"
#import "HomeViewCell.h"
#import "UIScrollView+SVInfiniteScrolling.h"

#define pageCount 5

@interface HouseListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *houseDataSource;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (assign, nonatomic) SInt64  nextCursor;
@property (assign, nonatomic) BOOL canLoadMore;

@end

@implementation HouseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [REngine shareInstance].uid = @"39";
    self.houseDataSource = [[NSMutableArray alloc] init];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    self.pullRefreshView.delegate = self;
    [self.tableView addSubview:self.pullRefreshView];
    
    [self refreshDataSource];
    
    
    
    __weak HouseListViewController *weakSelf = self;
    
    
    if (_vcType == VcType_Tenant_Collect || _vcType == VcType_Tenant_Contact) {
        
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf) {
                return;
            }
            if (!weakSelf.canLoadMore) {
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                weakSelf.tableView.showsInfiniteScrolling = NO;
                return ;
            }
            
            int queryType = 1;
            if (weakSelf.vcType == VcType_Tenant_Contact) {
                queryType = 2;
            }
            int tag = [[REngine shareInstance] getConnectTag];
            [[REngine shareInstance] getCollectHouseListWithNum:(int)weakSelf.nextCursor count:pageCount uid:[REngine shareInstance].uid queryType:queryType tag:tag];
            [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
                if (!jsonRet || errorMsg) {
                    if (!errorMsg.length) {
                        errorMsg = @"请求失败";
                    }
                    [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
                    return;
                }
                
                NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
                for (NSDictionary *dic in object) {
                    RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
                    [houseInfo setHouseInfoByDic:dic];
                    [weakSelf.houseDataSource addObject:houseInfo];
                }
                int totalNumber = [jsonRet intValueForKey:@"total"];
                weakSelf.canLoadMore = (weakSelf.houseDataSource.count < totalNumber);
                if (!weakSelf.canLoadMore) {
                    weakSelf.tableView.showsInfiniteScrolling = NO;
                }else{
                    weakSelf.tableView.showsInfiniteScrolling = YES;
                    weakSelf.nextCursor ++;
                }
                
                [weakSelf.tableView reloadData];
            } tag:tag];
        }];
        
    }else if (_vcType == VcType_Tenant_Bargain || _vcType == VcType_Landlord_Affirm){
        
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf) {
                return;
            }
            if (!weakSelf.canLoadMore) {
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                weakSelf.tableView.showsInfiniteScrolling = NO;
                return ;
            }
            
            int queryType = 1;
            if (weakSelf.vcType == VcType_Landlord_Affirm) {
                queryType = 2;
            }
            int tag = [[REngine shareInstance] getConnectTag];
            [[REngine shareInstance] getHouseRecordListWithNum:(int)weakSelf.nextCursor count:pageCount uid:[REngine shareInstance].uid queryType:queryType tag:tag];
            [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
                if (!jsonRet || errorMsg) {
                    if (!errorMsg.length) {
                        errorMsg = @"请求失败";
                    }
                    [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
                    return;
                }
                
                NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
                for (NSDictionary *dic in object) {
                    RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
                    [houseInfo setHouseInfoByDic:dic];
                    [weakSelf.houseDataSource addObject:houseInfo];
                }
                
                int totalNumber = [jsonRet intValueForKey:@"total"];
                weakSelf.canLoadMore = (weakSelf.houseDataSource.count < totalNumber);
                if (!weakSelf.canLoadMore) {
                    weakSelf.tableView.showsInfiniteScrolling = NO;
                }else{
                    weakSelf.tableView.showsInfiniteScrolling = YES;
                    weakSelf.nextCursor ++;
                }
                
                [weakSelf.tableView reloadData];
            } tag:tag];
        }];
        
        
        
    }else if (_vcType == VcType_Landlord_Publish){
        
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf) {
                return;
            }
            if (!weakSelf.canLoadMore) {
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                weakSelf.tableView.showsInfiniteScrolling = NO;
                return ;
            }
            
            int tag = [[REngine shareInstance] getConnectTag];
            [[REngine shareInstance] getHouseInfoWithNum:(int)weakSelf.nextCursor count:pageCount uid:[REngine shareInstance].uid tag:tag];
            [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
                if (!jsonRet || errorMsg) {
                    if (!errorMsg.length) {
                        errorMsg = @"请求失败";
                    }
                    [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
                    return;
                }
                NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
                for (NSDictionary *dic in object) {
                    RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
                    [houseInfo setHouseInfoByDic:dic];
                    [weakSelf.houseDataSource addObject:houseInfo];
                }
                
                int totalNumber = [jsonRet intValueForKey:@"total"];
                weakSelf.canLoadMore = (weakSelf.houseDataSource.count < totalNumber);
                if (!weakSelf.canLoadMore) {
                    weakSelf.tableView.showsInfiniteScrolling = NO;
                }else{
                    weakSelf.tableView.showsInfiniteScrolling = YES;
                    weakSelf.nextCursor ++;
                }
                
                [weakSelf.tableView reloadData];
            }tag:tag];
        }];
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:_titleText];
//    if (_vcType == VcType_Tenant_Collect) {
//        [self setTitle:@"我的收藏"];
//    }else if (_vcType == VcType_Tenant_Contact){
//        [self setTitle:@"已联系房东"];
//    }else if (_vcType == VcType_Tenant_Bargain){
//        [self setTitle:@"已成交记录"];
//    }else if (_vcType == VcType_Landlord_Affirm){
//        [self setTitle:@"待确认房源"];
//    }else if (_vcType == VcType_Landlord_Publish){
//        [self setTitle:@"已发布房源"];
//    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - custom
-(void)refreshDataSource{

    self.nextCursor = 1;
    __weak HouseListViewController *weakSelf = self;
    if (_vcType == VcType_Tenant_Collect || _vcType == VcType_Tenant_Contact) {
        
        int queryType = 1;
        if (_vcType == VcType_Tenant_Contact) {
            queryType = 2;
        }
        int tag = [[REngine shareInstance] getConnectTag];
        [[REngine shareInstance] getCollectHouseListWithNum:(int)self.nextCursor count:pageCount uid:[REngine shareInstance].uid queryType:queryType tag:tag];
        [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            [self.pullRefreshView finishedLoading];
            NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            
            weakSelf.houseDataSource = [[NSMutableArray alloc] init];
            NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
            for (NSDictionary *dic in object) {
                RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
                [houseInfo setHouseInfoByDic:dic];
                [weakSelf.houseDataSource addObject:houseInfo];
            }
            int totalNumber = [jsonRet intValueForKey:@"total"];
            weakSelf.canLoadMore = (weakSelf.houseDataSource.count < totalNumber);
            if (!weakSelf.canLoadMore) {
                weakSelf.tableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.tableView.showsInfiniteScrolling = YES;
                weakSelf.nextCursor ++;
            }
            
            [weakSelf.tableView reloadData];
        } tag:tag];
        
    }else if (_vcType == VcType_Tenant_Bargain || _vcType == VcType_Landlord_Affirm){
        
        int queryType = 1;
        if (_vcType == VcType_Landlord_Affirm) {
            queryType = 2;
        }
        int tag = [[REngine shareInstance] getConnectTag];
        [[REngine shareInstance] getHouseRecordListWithNum:(int)self.nextCursor count:pageCount uid:[REngine shareInstance].uid queryType:queryType tag:tag];
        [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            [self.pullRefreshView finishedLoading];
            NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            
            weakSelf.houseDataSource = [[NSMutableArray alloc] init];
            NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
            for (NSDictionary *dic in object) {
                RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
                [houseInfo setHouseInfoByDic:dic];
                [weakSelf.houseDataSource addObject:houseInfo];
            }
            
            int totalNumber = [jsonRet intValueForKey:@"total"];
            weakSelf.canLoadMore = (weakSelf.houseDataSource.count < totalNumber);
            if (!weakSelf.canLoadMore) {
                weakSelf.tableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.tableView.showsInfiniteScrolling = YES;
                weakSelf.nextCursor ++;
            }
            
            [weakSelf.tableView reloadData];
        } tag:tag];
        
    }else if (_vcType == VcType_Landlord_Publish){
        
        int tag = [[REngine shareInstance] getConnectTag];
        [[REngine shareInstance] getHouseInfoWithNum:(int)self.nextCursor count:pageCount uid:[REngine shareInstance].uid tag:tag];
        [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            [self.pullRefreshView finishedLoading];
            NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            weakSelf.houseDataSource = [[NSMutableArray alloc] init];
            NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
            for (NSDictionary *dic in object) {
                RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
                [houseInfo setHouseInfoByDic:dic];
                [weakSelf.houseDataSource addObject:houseInfo];
            }
            
            int totalNumber = [jsonRet intValueForKey:@"total"];
            weakSelf.canLoadMore = (weakSelf.houseDataSource.count < totalNumber);
            if (!weakSelf.canLoadMore) {
                weakSelf.tableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.tableView.showsInfiniteScrolling = YES;
                weakSelf.nextCursor ++;
            }
            
            [weakSelf.tableView reloadData];
        }tag:tag];
    }

}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshDataSource];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _houseDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HomeViewCell";
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    RHouseInfo *info = _houseDataSource[indexPath.row];
    cell.houseInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    RHouseInfo *info = _houseDataSource[indexPath.row];
    HouseDetailViewController *vc = [[HouseDetailViewController alloc] init];
    vc.houseInfo = info;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
