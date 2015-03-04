//
//  MineViewController.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "MineViewController.h"
#import "RTabBarViewController.h"
#import "HouseListViewController.h"
#import "REngine.h"

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *handleDataSource;
@property (nonatomic, strong) NSMutableDictionary *countDic;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (nonatomic, strong) IBOutlet UILabel *sectionLabelView;

@end

@implementation MineViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _handleDataSource = [[NSMutableArray alloc] init];
    [self loadDataSource];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"我的信息"];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

- (void)checkCount{
    
    int queryType = 1;
    if ([self isLandlordUser]) {
        queryType = 2;
    }
    __weak MineViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] getMineCountDataWithUid:[REngine shareInstance].uid queryType:queryType tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        if (!jsonRet || err){
            return ;
        }
        weakSelf.countDic = [[NSMutableDictionary alloc] initWithDictionary:jsonRet];
        [weakSelf.tableView reloadData];
        
    } tag:tag];
}

#pragma mark - custom
-(BOOL)isLandlordUser{
    
    return ([[REngine shareInstance].userInfo.userType intValue] == 1);
}

-(void)loadDataSource{
    
    [_handleDataSource removeAllObjects];
    if ([self isLandlordUser]) {
        [_handleDataSource addObject:@"发布房源"];
        [_handleDataSource addObject:@"待确认房源"];
        [_handleDataSource addObject:@"已发布房源"];
        self.sectionLabelView.text = @"   房东操作";
    }else{
        [_handleDataSource addObject:@"我的收藏"];
        [_handleDataSource addObject:@"已联系房东"];
        [_handleDataSource addObject:@"已成交记录"];
        self.sectionLabelView.text = @"   房客操作";
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.sectionView.frame.size.height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return self.sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _handleDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

static int desLabel_tag = 101;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100 - 35, 0, 100, 44)];
        desLabel.font = [UIFont systemFontOfSize:15];
        desLabel.textColor = [UIColor blackColor];
        desLabel.textAlignment = NSTextAlignmentRight;
        desLabel.backgroundColor = [UIColor clearColor];
        desLabel.tag = desLabel_tag;
        desLabel.hidden = YES;
        [cell addSubview:desLabel];
        
    }
    cell.textLabel.text = _handleDataSource[indexPath.row];
    
    UILabel *desLabel = (UILabel *)[cell viewWithTag:desLabel_tag];
    if (![self isLandlordUser]) {
        desLabel.hidden = NO;
        if (indexPath.row == 0) {
            desLabel.text = [NSString stringWithFormat:@"%d",[self.countDic intValueForKey:@"collectNum"]];
        }else if (indexPath.row == 1){
            desLabel.text = [NSString stringWithFormat:@"%d",[self.countDic intValueForKey:@"contactNum"]];
        }else if (indexPath.row == 2){
            desLabel.text = [NSString stringWithFormat:@"%d",[self.countDic intValueForKey:@"hasDealNum"]];
        }
    }else{
        
        desLabel.hidden = NO;
        if (indexPath.row == 0) {
            desLabel.hidden = YES;
        }else if (indexPath.row == 1){
            desLabel.text = [NSString stringWithFormat:@"%d",[self.countDic intValueForKey:@"beConfirmedNum"]];
        }else if (indexPath.row == 2){
            desLabel.text = [NSString stringWithFormat:@"%d",[self.countDic intValueForKey:@"publishNum"]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    NSString *titleText = _handleDataSource[indexPath.row];
    if (![self isLandlordUser]) {
        switch (indexPath.row) {
            case 0:
            {
                HouseListViewController *vc = [[HouseListViewController alloc] init];
                vc.vcType = VcType_Tenant_Collect;
                vc.titleText = titleText;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            {
                HouseListViewController *vc = [[HouseListViewController alloc] init];
                vc.vcType = VcType_Tenant_Contact;
                vc.titleText = titleText;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                HouseListViewController *vc = [[HouseListViewController alloc] init];
                vc.vcType = VcType_Tenant_Bargain;
                vc.titleText = titleText;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
            {
                
            }
                break;
            case 1:
            {
                HouseListViewController *vc = [[HouseListViewController alloc] init];
                vc.vcType = VcType_Landlord_Affirm;
                vc.titleText = titleText;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                HouseListViewController *vc = [[HouseListViewController alloc] init];
                vc.vcType = VcType_Landlord_Publish;
                vc.titleText = titleText;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}

@end
