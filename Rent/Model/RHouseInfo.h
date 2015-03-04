//
//  RHouseInfo.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHouseInfo : NSObject

@property(nonatomic, strong) NSString* hid;

@property(nonatomic, strong) NSString* price;
@property(nonatomic, strong) NSString* statusName;
@property(nonatomic, strong) NSString* typeA;
@property(nonatomic, strong) NSString* typeB;
@property(nonatomic, strong) NSString* typeC;
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* imgUrl;
//@property(nonatomic, readonly) NSURL* bgImgUrl;
@property(nonatomic, strong) NSURL* picUrl;

@property(nonatomic, strong) NSString* address;
@property(nonatomic, strong) NSString* area;
@property(nonatomic, strong) NSString* canCooking;
@property(nonatomic, strong) NSString* directionName;
@property(nonatomic, strong) NSString* fitmentName;
@property(nonatomic, strong) NSString* floor;
@property(nonatomic, strong) NSString* floorTop;
@property(nonatomic, strong) NSString* haveFurniture;
@property(nonatomic, strong) NSString* ownerId;
@property(nonatomic, strong) NSString* ownerName;
@property(nonatomic, strong) NSString* ownerPhone;
@property(nonatomic, strong) NSString* payTypeName;

@property(nonatomic, strong) NSMutableArray *picIds;
@property(nonatomic, readonly) NSArray* picURLs;

@property(nonatomic, strong) NSDictionary* houseInfoByJsonDic;

- (void)setHouseInfoByDic:(NSDictionary*)dic;

@end
