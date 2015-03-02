//
//  REngine.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUserInfo.h"

#define R_USERINFO_CHANGED_NOTIFICATION @"R_USERINFO_CHANGED_NOTIFICATION"

typedef void(^onAppServiceBlock)(NSInteger tag, NSDictionary* jsonRet, NSError* err);
typedef void(^onLSMsgFileProgressBlock)(NSUInteger receivedSize, long long expectedSize);

@interface REngine : NSObject

@property (nonatomic, strong) NSString* uid;
@property (nonatomic, strong) NSString* account;
@property (nonatomic, strong) NSString* userPassword;
@property (nonatomic, strong) RUserInfo* userInfo;
@property (nonatomic, readonly) NSDictionary* globalDefaultConfig;
@property (nonatomic,assign) BOOL debugMode;

@property (nonatomic,readonly) NSString* baseUrl;
@property (nonatomic, readonly) BOOL isFirstLoginInThisDevice;
@property (assign, nonatomic) BOOL bVisitor;
@property (assign, nonatomic) BOOL firstLogin;

//@property (nonatomic,assign) ServerPlatform serverPlatform;
@property (nonatomic,readonly) NSString* xeInstanceDocPath;

+ (REngine *)shareInstance;
+ (NSDictionary*)getReponseDicByContent:(NSData*)content err:(NSError*)err;
+ (NSString*)getErrorMsgWithReponseDic:(NSDictionary*)dic;
+ (NSString*)getErrorCodeWithReponseDic:(NSDictionary*)dic;
+ (NSString*)getSuccessMsgWithReponseDic:(NSDictionary*)dic;

- (void)saveAccount;
- (NSString*)getCurrentAccoutDocDirectory;

- (void)refreshUserInfo;
- (BOOL)hasAccoutLoggedin;
- (void)logout;
- (void)logout:(BOOL)removeAccout;

#pragma mark - Visitor
- (void)visitorLogin;
- (BOOL)needUserLogin:(NSString *)message;

//////////////////
- (int)getConnectTag;
- (void)addOnAppServiceBlock:(onAppServiceBlock)block tag:(int)tag;
- (void)removeOnAppServiceBlockForTag:(int)tag;
- (void)addGetCacheTag:(int)tag;
- (onAppServiceBlock)getonAppServiceBlockByTag:(int)tag;

//异步回调
- (void)getCacheReponseDicForTag:(int)tag complete:(void(^)(NSDictionary* jsonRet))complete;
- (void)getCacheReponseDicForUrl:(NSString*)url complete:(void(^)(NSDictionary* jsonRet))complete;

//保存cache
- (void)saveCacheWithString:(NSString*)str url:(NSString*)url;
- (void)clearAllCache;
- (unsigned long long)getUrlCacheSize;

#pragma mark - home
////http://localhost:8080/houseRenting/houseApi/getHouseListData?page=1&rows=10
//获取房源列表信息
- (BOOL)getHouseInfoWithNum:(NSUInteger)pagenum count:(NSUInteger)count uid:(NSString *)uid tag:(int)tag;
- (BOOL)getHouseInfoWithNum:(NSUInteger)pagenum count:(NSUInteger)count tag:(int)tag;
//筛选房源列表信息
- (BOOL)getHouseListWithNum:(NSUInteger)pagenum count:(NSUInteger)count qRoomAreaMin:(NSString *)aMin qRoomAreaMax:(NSString *)aMax qPriceMin:(NSString *)pMin qPriceMax:(NSString *)pMax qCanCooking:(NSString *)cooking qHaveFurniture:(NSString *)furniture qDirection:(NSString *)dire tag:(int)tag;
//获取房源详情
- (BOOL)getHouseDetailWithHid:(NSString *)houseId tag:(int)tag;

//版本更新
- (BOOL)getAppNewVersionWithAppType:(int)appType version:(NSInteger)version tag:(int)tag;

//我的收藏列表 及 已联系房东列表
- (BOOL)getCollectHouseListWithNum:(NSUInteger)pagenum count:(NSUInteger)count uid:(NSString *)uid  queryType:(int)queryType tag:(int)tag;
//租客已成交记录/房东待确认记录
- (BOOL)getHouseRecordListWithNum:(NSUInteger)pagenum count:(NSUInteger)count uid:(NSString *)uid  queryType:(int)queryType tag:(int)tag;
//我的首页数据统计
- (BOOL)getMineCountDataWithUid:(NSString *)uid queryType:(int)queryType tag:(int)tag;

@end
