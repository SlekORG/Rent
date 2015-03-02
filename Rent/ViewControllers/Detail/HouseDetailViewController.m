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

@interface HouseDetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *houseImageView;

@end

@implementation HouseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getHouseDetail];
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
}

- (void)getHouseDetail{
    __weak HouseDetailViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] getHouseDetailWithHid:self.houseInfo.hid tag:tag];
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

- (void)refreshHouse{
    if (![_houseInfo.picUrl isEqual:[NSNull null]]) {
        [self.houseImageView sd_setImageWithURL:_houseInfo.picUrl placeholderImage:[UIImage imageNamed:@"house_load_icon"]];
    }else{
        [self.houseImageView sd_setImageWithURL:nil];
        [self.houseImageView setImage:[UIImage imageNamed:@"house_load_icon"]];
    }

}

@end
