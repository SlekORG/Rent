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
#import "RAlertView.h"

#define pageCount 10
#define HOUSE_TYPE_NOT      0
#define HOUSE_TYPE_FINISH   1

@interface HouseListViewController ()<UITableViewDataSource,UITableViewDelegate,HomeCellDelegate>

@property (nonatomic, strong) NSMutableArray *houseDataSource;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *finishHouseDataSource;
@property (nonatomic, strong) IBOutlet UITableView *finishTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  nextCursor;
@property (assign, nonatomic) BOOL canLoadMore;
@property (assign, nonatomic) SInt64  nextCursor2;
@property (assign, nonatomic) BOOL canLoadMore2;

@end

@implementation HouseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.houseDataSource = [[NSMutableArray alloc] init];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    self.pullRefreshView.delegate = self;
    [self.tableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.finishTableView];
    self.pullRefreshView2.delegate = self;
    [self.finishTableView addSubview:self.pullRefreshView2];
    
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
            [[REngine shareInstance] getHouseInfoWithNum:(int)weakSelf.nextCursor count:pageCount uid:[REngine shareInstance].uid status:1 tag:tag];
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
        
        
        [self.finishTableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf) {
                return;
            }
            if (!weakSelf.canLoadMore2) {
                [weakSelf.finishTableView.infiniteScrollingView stopAnimating];
                weakSelf.finishTableView.showsInfiniteScrolling = NO;
                return ;
            }
            
            int tag = [[REngine shareInstance] getConnectTag];
            [[REngine shareInstance] getHouseInfoWithNum:(int)weakSelf.nextCursor count:pageCount uid:[REngine shareInstance].uid status:2 tag:tag];
            [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
                [weakSelf.finishTableView.infiniteScrollingView stopAnimating];
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
                    [weakSelf.finishHouseDataSource addObject:houseInfo];
                }
                
                int totalNumber = [jsonRet intValueForKey:@"total"];
                weakSelf.canLoadMore2 = (weakSelf.finishHouseDataSource.count < totalNumber);
                if (!weakSelf.canLoadMore2) {
                    weakSelf.finishTableView.showsInfiniteScrolling = NO;
                }else{
                    weakSelf.finishTableView.showsInfiniteScrolling = YES;
                    weakSelf.nextCursor2 ++;
                }
                
                [weakSelf.finishTableView reloadData];
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
//    }else
    if (_vcType == VcType_Landlord_Publish){
        [self setSegmentedControlWithSelector:@selector(segmentedControlAction:) items:@[@"未租",@"已租"]];
    }
}
-(void)feedsTypeSwitch:(int)tag needRefreshFeeds:(BOOL)needRefresh
{
    if (tag == HOUSE_TYPE_NOT) {
        //减速率
        self.finishTableView.decelerationRate = 0.0f;
        self.tableView.decelerationRate = 1.0f;
        self.finishTableView.hidden = YES;
        self.tableView.hidden = NO;
        
        if (!_houseDataSource) {
//            [self getCacheApplyActivity];
            [self refreshNotHouseData];
            return;
        }
        if (needRefresh) {
            [self refreshNotHouseData];
        }
    }else if (tag == HOUSE_TYPE_FINISH){
        
        self.finishTableView.decelerationRate = 1.0f;
        self.tableView.decelerationRate = 0.0f;
        self.tableView.hidden = YES;
        self.finishTableView.hidden = NO;
        if (!_finishHouseDataSource) {
//            [self getCacheCollectActivity];
            [self refreshFinishHouseData];
            return;
        }
        if (needRefresh) {
            [self refreshFinishHouseData];
        }
    }
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
        
        [self feedsTypeSwitch:HOUSE_TYPE_NOT needRefreshFeeds:YES];
    }

}

#pragma mark - 未租
-(void)refreshNotHouseData{
    
    self.nextCursor = 1;
    __weak HouseListViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] getHouseInfoWithNum:(int)self.nextCursor count:pageCount uid:[REngine shareInstance].uid status:1 tag:tag];
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
#pragma mark - 已租
-(void)refreshFinishHouseData{
    
    self.nextCursor2 = 1;
    __weak HouseListViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] getHouseInfoWithNum:(int)self.nextCursor2 count:pageCount uid:[REngine shareInstance].uid status:2 tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [self.pullRefreshView2 finishedLoading];
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.finishHouseDataSource = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
        for (NSDictionary *dic in object) {
            RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
            [houseInfo setHouseInfoByDic:dic];
            [weakSelf.finishHouseDataSource addObject:houseInfo];
        }
        
        int totalNumber = [jsonRet intValueForKey:@"total"];
        weakSelf.canLoadMore2 = (weakSelf.finishHouseDataSource.count < totalNumber);
        if (!weakSelf.canLoadMore2) {
            weakSelf.finishTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.finishTableView.showsInfiniteScrolling = YES;
            weakSelf.nextCursor2 ++;
        }
        
        [weakSelf.finishTableView reloadData];
    }tag:tag];
}

-(void)segmentedControlAction:(UISegmentedControl *)sender{
    
    _selectedSegmentIndex = sender.selectedSegmentIndex;
    [self feedsTypeSwitch:(int)_selectedSegmentIndex needRefreshFeeds:NO];
    switch (_selectedSegmentIndex) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            
        }
            break;
        default:
            break;
    }
}

-(void)customSegmentedControlAction:(NSInteger)index{
    [self.segmentedControl setSelectedSegmentIndex:index];
    _selectedSegmentIndex = index;
    [self feedsTypeSwitch:(int)index needRefreshFeeds:NO];
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshDataSource];
    }else if (view == self.pullRefreshView2){
        if (_vcType == VcType_Landlord_Publish) {
            [self refreshFinishHouseData];
        }
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
    if (tableView == self.finishTableView) {
        return _finishHouseDataSource.count;
    }
    return _houseDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

static int button_tag = 105;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HomeViewCell";
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        if (_vcType == VcType_Landlord_Publish) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(self.view.bounds.size.width - 72 - 12, 48, 72, 25);
            [button setBackgroundImage:[UIImage imageNamed:@"login_btn_enabled"] forState:0];
            [button addTarget:self action:@selector(handleClickAt:event:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.tag = button_tag;
            [cell addSubview:button];
        }
        if (_vcType == VcType_Tenant_Contact) {
            cell.type = cellType_contact;
            cell.delegate = self;
        }
        if (_vcType == VcType_Landlord_Affirm) {
            cell.type = cellType_Affirm;
            cell.delegate = self;
        }
    }
    UIButton *button = (UIButton *)[cell viewWithTag:button_tag];
    RHouseInfo *info;
    if (tableView == self.tableView) {
        info = _houseDataSource[indexPath.row];
        [button setTitle:@"标记已租" forState:0];
    }else if (tableView == self.finishTableView){
        [button setTitle:@"再次发布" forState:0];
        info = _finishHouseDataSource[indexPath.row];
    }
    cell.houseInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    RHouseInfo *info;
    if (tableView == self.tableView) {
        info = _houseDataSource[indexPath.row];
    }else if (tableView == self.finishTableView){
        info = _finishHouseDataSource[indexPath.row];
    }
    HouseDetailViewController *vc = [[HouseDetailViewController alloc] init];
    vc.houseInfo = info;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)handleClickAt:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    UITableView *tmpTableView;
    if (_selectedSegmentIndex == 0) {
        tmpTableView = self.tableView;
    }else if (_selectedSegmentIndex == 1){
        tmpTableView = self.finishTableView;
    }
    CGPoint currentTouchPosition = [touch locationInView:tmpTableView];
    NSIndexPath *indexPath = [tmpTableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        NSLog(@"indexPath: row:%d", (int)indexPath.row);
        __weak HouseListViewController *weakSelf = self;
        RHouseInfo *info;
        if (_selectedSegmentIndex == 0) {
            info = _houseDataSource[indexPath.row];
            RAlertView *alert = [[RAlertView alloc] initWithTitle:nil message:@"确定要标记已租吗？" cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"标记已租" okBlock:^{
                [weakSelf markHasRent:info];
            }];
            [alert show];
        }else if (_selectedSegmentIndex == 1){
            info = _finishHouseDataSource[indexPath.row];
            RAlertView *alert = [[RAlertView alloc] initWithTitle:nil message:@"确定要再次发布吗？" cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"再次发布" okBlock:^{
                [weakSelf againPublish:info];
            }];
            [alert show];
        }
        
    }
}

- (void)markHasRent:(RHouseInfo *)info{
    
    __weak HouseListViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] markHasBeenRentWithHouseId:info.hid tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        int status = [jsonRet intValueForKey:@"status"];
        if (status == 200) {
            NSInteger index = [weakSelf.houseDataSource indexOfObject:info];
            if (index == NSNotFound || index < 0 || index >= weakSelf.houseDataSource.count) {
                return;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [weakSelf.houseDataSource removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (weakSelf.finishHouseDataSource == nil) {
                weakSelf.finishHouseDataSource = [[NSMutableArray alloc] init];
            }
            [weakSelf.finishHouseDataSource insertObject:info atIndex:0];
            [weakSelf.finishTableView reloadData];
            //[weakSelf customSegmentedControlAction:1];
        }
    }tag:tag];
}

- (void)againPublish:(RHouseInfo *)info{
    
    __weak HouseListViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] resetPublishWithHouseId:info.hid tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        int status = [jsonRet intValueForKey:@"status"];
        if (status == 200) {
            NSInteger index = [weakSelf.finishHouseDataSource indexOfObject:info];
            if (index == NSNotFound || index < 0 || index >= weakSelf.finishHouseDataSource.count) {
                return;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [weakSelf.finishHouseDataSource removeObjectAtIndex:indexPath.row];
            [weakSelf.finishTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (weakSelf.houseDataSource == nil) {
                weakSelf.houseDataSource = [[NSMutableArray alloc] init];
            }
            [weakSelf.houseDataSource insertObject:info atIndex:0];
            [weakSelf.tableView reloadData];
            //[weakSelf customSegmentedControlAction:0];
        }
    }tag:tag];
}

- (void)confirmHouse:(RHouseInfo *)info{
    __weak HouseListViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    if (_vcType == VcType_Tenant_Contact) {
        [[REngine shareInstance] comfirmHouseWithUid:[REngine shareInstance].uid houseId:info.hid tag:tag];
    }else if(_vcType == VcType_Landlord_Affirm) {
        [[REngine shareInstance] checkHouseWithHouseId:info.hid tag:tag];
    }
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        int status = [jsonRet intValueForKey:@"status"];
        if (status == 200) {
            NSInteger index = [weakSelf.houseDataSource indexOfObject:info];
            if (index == NSNotFound || index < 0) {
                return;
            }
            for (RHouseInfo *houseInfo in weakSelf.houseDataSource) {
                if ([houseInfo.hid isEqual:info.hid]) {
                    if (_vcType == VcType_Tenant_Contact) {
                        houseInfo.statusName = @"已租出";
                        [weakSelf.tableView reloadData];
                        [weakSelf sendRemindSmsWithInfo:info];
                    }else if (_vcType == VcType_Landlord_Affirm){
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        [weakSelf.houseDataSource removeObjectAtIndex:indexPath.row];
                        [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    break;
                }
            }
        }
    }tag:tag];
}

- (void)didTouchCellBtnWithHouseInfo:(RHouseInfo *)houseInfo{
    if (_vcType == VcType_Tenant_Contact) {
        RAlertView *alert = [[RAlertView alloc] initWithTitle:nil message:@"你确定要租吗？" cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"确定" okBlock:^{
            [self confirmHouse:houseInfo];
        }];
        [alert show];
    }else if(_vcType == VcType_Landlord_Affirm) {
        RAlertView *alert = [[RAlertView alloc] initWithTitle:nil message:@"你同意出租吗？" cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"确定" okBlock:^{
            [self confirmHouse:houseInfo];
        }];
        [alert show];
    }
}

- (void)sendRemindSmsWithInfo:(RHouseInfo *)houseInfo{
    __weak HouseListViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] sendRemindSmsWithUid:[REngine shareInstance].uid houseId:houseInfo.hid smsType:2 tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        int status = [jsonRet intValueForKey:@"status"];
        if (status == 200) {
            [XEProgressHUD AlertSuccess:@"已短信通知房东" At:weakSelf.view];
        }
    }tag:tag];
}

@end
