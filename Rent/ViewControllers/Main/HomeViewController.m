//
//  HomeViewController.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "HomeViewController.h"
#import "RTabBarViewController.h"
#import "ODRefreshControl.h"
#import "REngine.h"
#import "XEProgressHUD.h"
#import "RHouseInfo.h"
#import "HomeViewCell.h"
#import "HouseDetailViewController.h"
#import "HouseFilterViewController.h"
#import "LoginViewController.h"
#import "RNavigationController.h"
#import "UIScrollView+SVInfiniteScrolling.h"

#define pageCount 10

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{
    ODRefreshControl *_themeControl;
    BOOL _isScrollViewDrag;
}

@property (strong, nonatomic) IBOutlet UITableView *findTableView;
@property (strong, nonatomic) NSMutableArray *houseArray;

@property (assign, nonatomic) SInt64  nextCursor;
@property (assign, nonatomic) BOOL canLoadMore;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getHouseInfo];
    
    _themeControl = [[ODRefreshControl alloc] initInScrollView:self.findTableView];
    [_themeControl addTarget:self action:@selector(themeBeginPull:) forControlEvents:UIControlEventValueChanged];
    
    
    __weak HomeViewController *weakSelf = self;
    [self.findTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (!weakSelf.canLoadMore) {
            [weakSelf.findTableView.infiniteScrollingView stopAnimating];
            weakSelf.findTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[REngine shareInstance] getConnectTag];
        [[REngine shareInstance] getHouseInfoWithNum:(int)weakSelf.nextCursor count:pageCount uid:nil status:0 tag:tag];
        [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            [weakSelf.findTableView.infiniteScrollingView stopAnimating];
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
                [weakSelf.houseArray addObject:houseInfo];
            }
            int totalNumber = [jsonRet intValueForKey:@"total"];
            weakSelf.canLoadMore = (weakSelf.houseArray.count < totalNumber);
            if (!weakSelf.canLoadMore) {
                weakSelf.findTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.findTableView.showsInfiniteScrolling = YES;
                weakSelf.nextCursor ++;
            }
            
            [weakSelf.findTableView reloadData];
        } tag:tag];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"找房"];
    [self setLeftButtonWithTitle:@"筛选" selector:@selector(filterAction)];
    if (![REngine shareInstance].uid) {
        [self setRightButtonWithTitle:@"登录" selector:@selector(loginAction)];
    }
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

- (void)getHouseInfo{
    
    _nextCursor = 1;
    __weak HomeViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];

    [[REngine shareInstance] getHouseInfoWithNum:(int)weakSelf.nextCursor count:pageCount uid:nil status:0 tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [XEProgressHUD AlertLoadDone];
//        [self.pullRefreshView finishedLoading];
        _isScrollViewDrag = NO;
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            [_themeControl endRefreshing:NO];
            return;
        }
        weakSelf.houseArray = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
        for (NSDictionary *dic in object) {
            RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
            [houseInfo setHouseInfoByDic:dic];
            [weakSelf.houseArray addObject:houseInfo];
        }
        
        int totalNumber = [jsonRet intValueForKey:@"total"];
        weakSelf.canLoadMore = (weakSelf.houseArray.count < totalNumber);
        if (!weakSelf.canLoadMore) {
            weakSelf.findTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.findTableView.showsInfiniteScrolling = YES;
            weakSelf.nextCursor ++;
        }
        [weakSelf.findTableView reloadData];
        [_themeControl endRefreshing:YES];
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _houseArray.count;
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
        
    RHouseInfo *info = _houseArray[indexPath.row];
    cell.houseInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    RHouseInfo *info = _houseArray[indexPath.row];
    HouseDetailViewController *vc = [[HouseDetailViewController alloc] init];
    vc.houseInfo = info;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isScrollViewDrag = YES;
}

#pragma mark - ODRefreshControl
- (void)themeBeginPull:(ODRefreshControl *)refreshControl
{
    if (_isScrollViewDrag) {
        //[self performSelector:@selector(getHouseInfo) withObject:self afterDelay:0.3];
        [self getHouseInfo];
    }
}

- (void)loginAction{
    LoginViewController *loginVc = [[LoginViewController alloc] init];
    loginVc.showBackButton = YES;
    RNavigationController* navigationController = [[RNavigationController alloc] initWithRootViewController:loginVc];
    navigationController.navigationBarHidden = YES;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)filterAction{
    __weak HomeViewController *weakSelf = self;
    HouseFilterViewController *hfVC = [[HouseFilterViewController alloc] init];
    hfVC.housesFilterCallBack = ^(NSArray* array){
        if (array) {
            weakSelf.houseArray = [[NSMutableArray alloc] init];
            [weakSelf.houseArray addObjectsFromArray:array];
            [weakSelf.findTableView reloadData];
            if (array.count == 0) {
                 [XEProgressHUD lightAlert:@"没有符合筛选要求的房源"];
            }
        }
    };
    [self.navigationController pushViewController:hfVC animated:YES];
}

@end
