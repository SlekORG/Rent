//
//  RHouseInfo.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "RHouseInfo.h"
#import "JSONKit.h"
#import "REngine.h"

@implementation RHouseInfo

- (void)setHouseInfoByDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _houseInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    @try {
        [self doSetHouseInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####RHouseInfo setHouseInfoByJsonDic exception:%@", exception);
    }
    
    //self.jsonString = [_houseInfoByJsonDic JSONString];
    
}

- (void)doSetHouseInfoByJsonDic:(NSDictionary*)dic {
    if ([dic objectForKey:@"id"]) {
        _hid = [dic objectForKey:@"id"];
    }
    if ([dic objectForKey:@"imgUrl"]) {
        _imgUrl = [dic objectForKey:@"imgUrl"];
    }
    if ([dic objectForKey:@"price"]) {
        _price = [dic objectForKey:@"price"];
    }
    if ([dic objectForKey:@"statusName"]) {
        _statusName = [dic objectForKey:@"statusName"];
    }
    if ([dic objectForKey:@"title"]) {
        _title = [[dic objectForKey:@"title"] description];
    }
    if ([dic objectForKey:@"typeA"]) {
        _typeA = [dic objectForKey:@"typeA"];
    }
    if ([dic objectForKey:@"typeB"]) {
        _typeB = [dic objectForKey:@"typeB"];
    }
    if ([dic objectForKey:@"typeC"]) {
        _typeC = [dic objectForKey:@"typeC"];
    }
    if ([dic objectForKey:@"address"]) {
        _address = [dic objectForKey:@"address"];
    }
    if ([dic objectForKey:@"area"]) {
        _area = [dic objectForKey:@"area"];
    }
    if ([dic objectForKey:@"canCooking"]) {
        _canCooking = [dic objectForKey:@"canCooking"];
    }
    if ([dic objectForKey:@"directionName"]) {
        _directionName = [dic objectForKey:@"directionName"];
    }
    if ([dic objectForKey:@"fitmentName"]) {
        _fitmentName = [dic objectForKey:@"fitmentName"];
    }
    if ([dic objectForKey:@"floor"]) {
        _floor = [dic objectForKey:@"floor"];
    }
    if ([dic objectForKey:@"floorTop"]) {
        _floorTop = [dic objectForKey:@"floorTop"];
    }
    if ([dic objectForKey:@"haveFurniture"]) {
        _haveFurniture = [dic objectForKey:@"haveFurniture"];
    }
    if ([dic objectForKey:@"ownerId"]) {
        _ownerId = [dic objectForKey:@"ownerId"];
    }
    if ([dic objectForKey:@"ownerName"]) {
        _ownerName = [dic objectForKey:@"ownerName"];
    }
    if ([dic objectForKey:@"ownerPhone"]) {
        _ownerPhone = [dic objectForKey:@"ownerPhone"];
    }
    if ([dic objectForKey:@"payTypeName"]) {
        _payTypeName = [dic objectForKey:@"payTypeName"];
    }
    
    id objectForKey = [dic arrayObjectForKey:@"img"];
    if (objectForKey) {
        _picIds = [NSMutableArray array];
        for (NSDictionary *objectDic in objectForKey) {
            [_picIds addObject:[objectDic objectForKey:@"imgUrl"]];
        }
    }
}

- (NSURL *)picUrl {
    if (_imgUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[REngine shareInstance] baseUrl], _imgUrl]];
}

- (NSArray *)picURLs{
    NSMutableArray* urls = [[NSMutableArray alloc] init];
    for (NSString* picID in _picIds) {
        [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[REngine shareInstance] baseUrl] ,picID]]];
    }
    return urls;
}
@end
