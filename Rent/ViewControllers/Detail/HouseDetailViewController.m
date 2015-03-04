//
//  HouseDetailViewController.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "HouseDetailViewController.h"
#import "REngine.h"
#import "XEProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "RAlertView.h"

@interface HouseDetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *houseImageView;
@property (strong, nonatomic) IBOutlet UILabel *houseTitle;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeAbcLabel;
@property (strong, nonatomic) IBOutlet UILabel *fitmentLabel;
@property (strong, nonatomic) IBOutlet UILabel *areaLabel;
@property (strong, nonatomic) IBOutlet UILabel *directionLabel;
@property (strong, nonatomic) IBOutlet UILabel *floorLabel;
@property (strong, nonatomic) IBOutlet UILabel *cookingLabel;
@property (strong, nonatomic) IBOutlet UILabel *furnitureLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *ownerNameLabel;

@end

@implementation HouseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getHouseDetail];
    [_containerView setContentSize:CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT*1.2)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"房源详情"];
    [self setRightButtonWithImageName:@"nav_collect_un_icon" selector:@selector(collectAction)];
}

- (void)collectAction{
    NSLog(@"=============收藏");
    __weak HouseDetailViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] collectHouseWithUid:[REngine shareInstance].uid houseId:self.houseInfo.hid type:@"1" tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [XEProgressHUD AlertSuccess:@"收藏成功" At:weakSelf.view];
    }tag:tag];
}

- (void)getHouseDetail{
    __weak HouseDetailViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] getHouseDetailWithUid:[REngine shareInstance].uid houseId:self.houseInfo.hid tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSLog(@"jsonRet==========%@",jsonRet);
        NSDictionary *dic = jsonRet;
        RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
        [houseInfo setHouseInfoByDic:dic];
        weakSelf.houseInfo = houseInfo;
        [weakSelf refreshHouse];
    }tag:tag];
}

- (IBAction)callAction:(id)sender {
    __weak HouseDetailViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] collectHouseWithUid:[REngine shareInstance].uid houseId:self.houseInfo.hid type:@"2" tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSString *seletePhoneNum = [NSString stringWithFormat:@"%@",weakSelf.houseInfo.ownerPhone];
        RAlertView *alertView = [[RAlertView alloc] initWithTitle:nil message:seletePhoneNum cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"呼叫" okBlock:^{
            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", seletePhoneNum]];
            [[UIApplication sharedApplication] openURL:URL];
        }];
        [alertView show];
    }tag:tag];

}

- (void)refreshHouse{
    if (![_houseInfo.picUrl isEqual:[NSNull null]]) {
        [self.houseImageView sd_setImageWithURL:_houseInfo.picUrl placeholderImage:[UIImage imageNamed:@"house_load_icon"]];
    }else{
        [self.houseImageView sd_setImageWithURL:nil];
        [self.houseImageView setImage:[UIImage imageNamed:@"house_load_icon"]];
    }
    self.houseTitle.text = _houseInfo.title;
    self.addressLabel.text = _houseInfo.address;
    self.priceLabel.text = [NSString stringWithFormat:@"%@/月",_houseInfo.price];
    if (_houseInfo.payTypeName.length > 0) {
        self.priceLabel.text = [NSString stringWithFormat:@"%@(%@)",self.priceLabel.text,_houseInfo.payTypeName];
    }
    self.typeAbcLabel.text = [NSString stringWithFormat:@"%@室%@厅%@卫",_houseInfo.typeA,_houseInfo.typeB,_houseInfo.typeC];
    self.fitmentLabel.text = _houseInfo.fitmentName;
    self.areaLabel.text = [NSString stringWithFormat:@"%@",_houseInfo.area];
    self.directionLabel.text = _houseInfo.directionName;
    self.floorLabel.text = [NSString stringWithFormat:@"%@/%@",_houseInfo.floor,_houseInfo.floorTop];
    self.cookingLabel.text = _houseInfo.canCooking;
    self.furnitureLabel.text = _houseInfo.haveFurniture;
    self.descLabel.text = _houseInfo.address;
    self.ownerNameLabel.text = _houseInfo.ownerName;
}

@end
