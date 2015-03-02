//
//  HouseFilterViewController.m
//  Rent
//
//  Created by KID on 15/3/2.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "HouseFilterViewController.h"
#import "REngine.h"
#import "XEProgressHUD.h"
#import "RAlertView.h"
#import "RHouseInfo.h"

@interface HouseFilterViewController ()

@property (strong, nonatomic) NSMutableArray *housesArray;

@end

@implementation HouseFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"房源筛选"];
}

- (IBAction)confirmAction:(id)sender {
    __weak HouseFilterViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    
    [[REngine shareInstance] getHouseListWithNum:1 count:10 qRoomAreaMin:@"1" qRoomAreaMax:@"15" qPriceMin:nil qPriceMax:nil qCanCooking:nil qHaveFurniture:nil qDirection:nil tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSLog(@"====================%@",jsonRet);
        weakSelf.housesArray = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
        for (NSDictionary *dic in object) {
            RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
            [houseInfo setHouseInfoByDic:dic];
            [weakSelf.housesArray addObject:houseInfo];
        }
        [self.navigationController popViewControllerAnimated:YES];
        if (_housesFilterCallBack) {
            _housesFilterCallBack(weakSelf.housesArray);
        }
    }tag:tag];
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
