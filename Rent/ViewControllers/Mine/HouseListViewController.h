//
//  HouseListViewController.h
//  Rent
//
//  Created by KID on 15/3/2.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "RSuperViewController.h"

typedef enum VcType_{
    VcType_Tenant_Collect = 0,   //我的收藏
    VcType_Tenant_Contact,       //已联系房东
    VcType_Tenant_Bargain,       //已成交记录
    VcType_Landlord_Affirm,      //待确认房源
    VcType_Landlord_Publish,     //已发布房源
}VcType;
@interface HouseListViewController : RSuperViewController

@property (nonatomic, assign) VcType vcType;
@property (nonatomic, strong) NSString *titleText;

@end
