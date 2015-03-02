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

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{
    ODRefreshControl *_themeControl;
    BOOL _isScrollViewDrag;
}

@property (strong, nonatomic) IBOutlet UITableView *findTableView;
@property (strong, nonatomic) NSMutableArray *houseArray;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getHouseInfo];
    
    _themeControl = [[ODRefreshControl alloc] initInScrollView:self.findTableView];
    [_themeControl addTarget:self action:@selector(themeBeginPull:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"找房"];
    [self setLeftButtonWithTitle:@"筛选" selector:@selector(filterAction)];
    [self setRightButtonWithTitle:@"登录" selector:@selector(loginAction)];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

- (void)getHouseInfo{
    __weak HomeViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];

    [[REngine shareInstance] getHouseInfoWithNum:1 count:10 uid:nil tag:tag];
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
        [_themeControl endRefreshing:YES];
        weakSelf.houseArray = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
        for (NSDictionary *dic in object) {
            RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
            [houseInfo setHouseInfoByDic:dic];
            [weakSelf.houseArray addObject:houseInfo];
        }
        [weakSelf.findTableView reloadData];
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
        [self performSelector:@selector(getHouseInfo) withObject:self afterDelay:1.0];
    }
}

- (void)loginAction{
    NSLog(@"==========登录");
}

- (void)filterAction{
    __weak HomeViewController *weakSelf = self;
    HouseFilterViewController *hfVC = [[HouseFilterViewController alloc] init];
    hfVC.housesFilterCallBack = ^(NSArray* array){
        if (array) {
            weakSelf.houseArray = [[NSMutableArray alloc] init];
            [weakSelf.houseArray addObjectsFromArray:array];
            [weakSelf.findTableView reloadData];
        }
    };
    [self.navigationController pushViewController:hfVC animated:YES];
}

@end
