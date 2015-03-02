//
//  HouseFilterViewController.h
//  Rent
//
//  Created by KID on 15/3/2.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "RSuperViewController.h"

typedef void(^HousesFilterCallBack)(NSArray * array);

@interface HouseFilterViewController : RSuperViewController

@property (nonatomic, strong) HousesFilterCallBack housesFilterCallBack;

@end
