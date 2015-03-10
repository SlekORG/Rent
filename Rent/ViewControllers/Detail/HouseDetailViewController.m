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
#import "MWPhotoBrowser.h"
#import "LoginViewController.h"
#import "RNavigationController.h"

@interface HouseDetailViewController ()<MWPhotoBrowserDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *telImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UIButton *clickButton;
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


- (IBAction)imageClickAction:(id)sender;

@end

@implementation HouseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_containerView setContentSize:CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT*1.1)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self getHouseDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"房源详情"];
    if ([[REngine shareInstance].userInfo.userType intValue] == 2) {
       [self setRightButtonWithImageName:@"nav_collect_un_icon" selector:@selector(collectAction)];
    }
}

-(BOOL)isCollect{
    if (_houseInfo.isLike != 0) {
        return YES;
    }
    return NO;
}

- (void)collectAction{
    __weak HouseDetailViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    if ([self isCollect]) {
        [[REngine shareInstance] cancelCollectHouseWithUid:[REngine shareInstance].uid houseId:self.houseInfo.hid tag:tag];
        [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            weakSelf.houseInfo.isLike = 0;
            [weakSelf refreshNavBar];
            [XEProgressHUD AlertSuccess:@"取消收藏成功" At:weakSelf.view];
        }tag:tag];
    }else{
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
            weakSelf.houseInfo.isLike = 1;
            [weakSelf refreshNavBar];
            [XEProgressHUD AlertSuccess:@"收藏成功" At:weakSelf.view];
        }tag:tag];
    }
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
        [weakSelf refreshNavBar];
        [weakSelf refreshHouse];
    }tag:tag];
}

- (IBAction)callAction:(id)sender {
    if (![REngine shareInstance].uid) {
        LoginViewController *loginVc = [[LoginViewController alloc] init];
        loginVc.showBackButton = YES;
        RNavigationController* navigationController = [[RNavigationController alloc] initWithRootViewController:loginVc];
        navigationController.navigationBarHidden = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        return;
    }
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
            [weakSelf sendRemindSms];
            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", seletePhoneNum]];
            [[UIApplication sharedApplication] openURL:URL];
        }];
        [alertView show];
    }tag:tag];
}

- (void)sendRemindSms{
    __weak HouseDetailViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] sendRemindSmsWithUid:[REngine shareInstance].uid houseId:_houseInfo.hid smsType:1 tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
    }tag:tag];
}

- (void)refreshNavBar{
    if (![self isCollect]) {
        [self.titleNavBarRightBtn setImage:[UIImage imageNamed:@"nav_collect_un_icon"] forState:UIControlStateNormal];
    }else{
        [self.titleNavBarRightBtn setImage:[UIImage imageNamed:@"nav_collect_icon"] forState:UIControlStateNormal];
    }
}

- (void)refreshHouse{
//    if (![_houseInfo.picUrl isEqual:[NSNull null]]) {
//        [self.houseImageView sd_setImageWithURL:_houseInfo.picUrl placeholderImage:[UIImage imageNamed:@"house_load_icon"]];
//    }else{
//        [self.houseImageView sd_setImageWithURL:nil];
//        [self.houseImageView setImage:[UIImage imageNamed:@"house_load_icon"]];
//    }
    self.houseTitle.text = _houseInfo.title;
    self.addressLabel.text = _houseInfo.address;
    self.priceLabel.text = [NSString stringWithFormat:@"%@/月",_houseInfo.price];
    if (_houseInfo.payTypeName.length > 0) {
        self.priceLabel.text = [NSString stringWithFormat:@"%@(%@)",self.priceLabel.text,_houseInfo.payTypeName];
    }
    self.typeAbcLabel.text = [NSString stringWithFormat:@"%@室%@厅%@卫",_houseInfo.typeA,_houseInfo.typeB,_houseInfo.typeC];
    if (![_houseInfo.fitmentName isEqual:[NSNull null]]) {
        self.fitmentLabel.text = _houseInfo.fitmentName;
    }else{
        self.fitmentLabel.text = @"";
    }
    self.areaLabel.text = [NSString stringWithFormat:@"%@",_houseInfo.area];
    self.directionLabel.text = _houseInfo.directionName;
    self.floorLabel.text = [NSString stringWithFormat:@"%@/%@",_houseInfo.floor,_houseInfo.floorTop];
    self.cookingLabel.text = _houseInfo.canCooking;
    self.furnitureLabel.text = _houseInfo.haveFurniture;
    self.descLabel.text = _houseInfo.houseDescription;
    if ([REngine shareInstance].uid) {
        self.ownerNameLabel.text = _houseInfo.ownerName;
    }else{
        self.ownerNameLabel.text = @"注册&登录";
        self.telImageView.hidden = YES;
    }
    [self.imageScrollView removeFromSuperview];
    [self.containerView addSubview:self.imageScrollView];
    int index = 0;
    if(self.houseInfo.picIds.count > 0){
        for (NSString *picUrl in self.houseInfo.picIds) {
            XELog(@"picUrl = %@",picUrl);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(index*self.imageScrollView.frame.size.width, 0, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.userInteractionEnabled = YES;
            [imageView sd_setImageWithURL:[self.houseInfo.picURLs objectAtIndex:index] placeholderImage:[UIImage imageNamed:@"house_load_icon"]];
            [self.imageScrollView addSubview:imageView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = self.imageScrollView.frame;
            [button addTarget:self action:@selector(imageClickAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = index;
            [imageView addSubview:button];
            
            index ++;
        }
        [self.imageScrollView setContentSize:CGSizeMake((index)*self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height)];
        self.imageScrollView.pagingEnabled = YES;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
    }else{
        self.imageScrollView.hidden = YES;
        self.houseImageView.hidden = NO;
        [self.houseImageView setImage:[UIImage imageNamed:@"house_load_icon"]];
    }
}

- (void)didTapOnItemAtIndex:(NSUInteger)position{
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:position];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.houseInfo.picIds.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSArray* picUrls = self.houseInfo.picURLs;
    if (index < picUrls.count){
        MWPhoto* mwPhoto = [[MWPhoto alloc] initWithURL:[picUrls objectAtIndex:index]];
        return mwPhoto;
    }
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)imageClickAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self didTapOnItemAtIndex:btn.tag];
}
@end
