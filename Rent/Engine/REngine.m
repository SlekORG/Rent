//
//  REngine.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "REngine.h"
#import "EGOCache.h"
#import "JSONKit.h"
#import "PathHelper.h"
#import "RCommonUtils.h"
#import "AFNetworking.h"
//#import "XEProgressHUD.h"
#import "URLHelper.h"
#import "NSDictionary+objectForKey.h"
#import "QHQnetworkingTool.h"
#import "RSettingConfig.h"
#import "RAlertView.h"
#import "AppDelegate.h"
#import "RNavigationController.h"

#define CONNECT_TIMEOUT 20

static NSString* API_URL = @"http://218.244.156.120:8080";

static REngine* s_ShareInstance = nil;

@interface REngine (){
    
    int _connectTag;
    
    NSMutableDictionary* _onAppServiceBlockMap;
    //....
    EGOCache* _cacheInstance;
    
    NSDictionary* _globalDefaultConfig;
    
    NSMutableSet* _needCacheUrls;
    
    NSMutableDictionary* _urlCacheTagMap;
    
    NSMutableDictionary* _urlTagMap;
}

@end

@implementation REngine

+ (REngine *)shareInstance{
    @synchronized(self) {
        if (s_ShareInstance == nil) {
            s_ShareInstance = [[REngine alloc] init];
        }
    }
    return s_ShareInstance;
}

+ (NSDictionary*)getReponseDicByContent:(NSData*)content err:(NSError*)err{
    if (err || !content || content.length == 0) {
        NSLog(@"#######content=nil");
        return nil;
    }
    NSDictionary* json = [content objectFromJSONData];
    return json;
}

+ (NSString*)getErrorMsgWithReponseDic:(NSDictionary*)dic{
    if (dic == nil) {
        return @"请检查网络连接是否正常";
    }
    if ([[dic objectForKey:@"code"] intValue] == 0){
        return nil;
    }else{
        NSString* error = [dic objectForKey:@"result"];
        if (!error) {
            error = [dic objectForKey:@"result"];
        }
        if (error == nil) {
            error = @"unknow error";
        }
        return error;
    }
}

+ (NSString*)getErrorCodeWithReponseDic:(NSDictionary*)dic {
    
    return [[[dic dictionaryObjectForKey:@"result"] stringObjectForKey:@"error_code"] description];
}

+ (NSString*)getSuccessMsgWithReponseDic:(NSDictionary*)dic{
    
    if (dic == nil) {
        return nil;
    }
    if ([[dic objectForKey:@"code"] intValue] == 0){
        return [dic objectForKey:@"result"];
    }else{
        return nil;
    }
}

- (EGOCache *)getCacheInstance{
    @synchronized(self) {
        if (_uid.length == 0) {
            return [EGOCache globalCache];
        }else{
            if (_cacheInstance == nil) {
                NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                cachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:_uid] copy];
                _cacheInstance = [[EGOCache alloc] initWithCacheDirectory:cachesDirectory];
                _cacheInstance.defaultTimeoutInterval = 365*24*60*60;
            }
        }
    }
    return _cacheInstance;
}

- (id)init{
    self = [super init];
    
    _connectTag = 100;
    _onAppServiceBlockMap = [[NSMutableDictionary alloc] init];
    _needCacheUrls = [[NSMutableSet alloc] init];
    _urlCacheTagMap = [[NSMutableDictionary alloc] init];
    _urlTagMap = [[NSMutableDictionary alloc] init];
    
    _uid = nil;
    _userPassword = nil;
    
    //获取用户信息
    [self loadAccount];
    
    _userInfo = [[RUserInfo alloc] init];
    _userInfo.uid = _uid;
    [self loadUserInfo];
    
//    _serverPlatform = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"serverPlatform"];
//    if (_serverPlatform == 0)
//    {
//        _serverPlatform = OnlinePlatform;//默认线上平台
//    }
    
    //设置访问
    [self setDebugMode:[[NSUserDefaults standardUserDefaults] boolForKey:@"clientDebugMode2"]];
    
//    [self serverInit];
    
    _xeInstanceDocPath = [PathHelper documentDirectoryPathWithName:@"XE_Path"];
    NSLog(@"cache file path: %@", _xeInstanceDocPath);
    
    return self;
}

//- (void)serverInit{
//    //    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
//    if (self.serverPlatform == TestPlatform) {
//        API_URL = @"http://192.168.16.29/api";
//    } else {
//        API_URL = @"http://xiaor123.cn:801/api";
//    }
//}

- (void)logout{
    _firstLogin = YES;
    _isFirstLoginInThisDevice = NO;
    [self logout:NO];
}

- (void)logout:(BOOL)removeAccout{
    
    if (removeAccout) {
        _account = nil;
    }
    
    _userPassword = nil;
    [self saveAccount];
    _userInfo = [[RUserInfo alloc] init];
    [RSettingConfig logout];
    _cacheInstance = nil;
    _bVisitor = YES;
}

- (NSString*)getCurrentAccoutDocDirectory{
    return [PathHelper documentDirectoryPathWithName:[NSString stringWithFormat:@"accounts/%@", _uid]];
}

- (NSDictionary*)globalDefaultConfig {
    if (_globalDefaultConfig == nil) {
        _globalDefaultConfig = [NSDictionary dictionaryWithContentsOfFile:[self getGlobalDefaultConfigPath]];
        
        if (_globalDefaultConfig == nil) {
            _globalDefaultConfig = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"globalDefaultConfig" ofType:nil]];
        }
    }
    
    return _globalDefaultConfig;
}

- (void)setGlobalDefaultConfig:(NSDictionary *)globalDefaultConfig {
    _globalDefaultConfig = globalDefaultConfig;
}

- (NSString *)getGlobalDefaultConfigPath{
    NSString *filePath = [[PathHelper documentDirectoryPathWithName:nil] stringByAppendingPathComponent:@"globalDefaultConfig"];
    return filePath;
}

- (NSString *)getAccountsStoragePath{
    NSString *filePath = [[PathHelper documentDirectoryPathWithName:nil] stringByAppendingPathComponent:@"account"];
    return filePath;
}

- (void)loadUserInfo{
    if(!_uid){
        return;
    }
    NSString *path = [[self getCurrentAccoutDocDirectory] stringByAppendingPathComponent:@"myUserInfo.xml"];
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!jsonString) {
        [self refreshUserInfo];
    }
    NSDictionary *userDic = [jsonString objectFromJSONString];
    XELog(@"REngine loadUserInfo userDic =%@ ",userDic);
    if (userDic) {
        if (_userInfo == nil) {
            _userInfo = [[RUserInfo alloc] init];
        }
        [_userInfo setUserInfoByJsonDic:userDic];
    }
}

- (void)saveUserInfo{
    if (!_uid) {
        return;
    }
    
    if (!self.userInfo.jsonString) {
        return;
    }
    NSString* path = [[self getCurrentAccoutDocDirectory] stringByAppendingPathComponent:@"myUserInfo.xml"];
    [self.userInfo.jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)setUserInfo:(RUserInfo *)userInfo{
    _userInfo = userInfo;
    [[RSettingConfig staticInstance] setUserCfg:_userInfo.userInfoByJsonDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:R_USERINFO_CHANGED_NOTIFICATION object:self];
    [self saveUserInfo];
}


- (void)loadAccount{
    NSDictionary * accountDic = [NSDictionary dictionaryWithContentsOfFile:[self getAccountsStoragePath]];
    //.....account信息
    _uid = [accountDic objectForKey:@"uid"];
    _account = [accountDic objectForKey:@"account"];
    _userPassword = [accountDic objectForKey:@"accountPwd"];
}

- (void)saveAccount{
    NSMutableDictionary* accountDic= [NSMutableDictionary dictionaryWithCapacity:2];
    if (_uid) {
        [accountDic setValue:_uid forKey:@"uid"];
    }
    if (_account)
        [accountDic setValue:_account forKey:@"account"];
    if(_userPassword)
        [accountDic setValue:_userPassword forKey:@"accountPwd"];
    [accountDic writeToFile:[self getAccountsStoragePath] atomically:NO];
}

-(void)removeAccount{
    [[NSFileManager defaultManager] removeItemAtPath:[self getAccountsStoragePath] error:nil];
}

- (void)setDebugMode:(BOOL)debugMode save:(BOOL)save {
    _debugMode = debugMode;
    if (save) {
        [[NSUserDefaults standardUserDefaults] setBool:_debugMode forKey:@"clientDebugMode2"];
    }
}

- (void)setDebugMode:(BOOL)debugMode{
    
    [self setDebugMode:debugMode save:YES];
}

- (BOOL)hasAccoutLoggedin{
    NSLog(@"_account=%@, _userPassword=%@, _uid=%@", _account, _userPassword, _uid);
    return (_account && _userPassword && _uid);
}

-(NSString *)baseUrl{
    return API_URL;
}

//- (void)setServerPlatform:(ServerPlatform)serverPlatform {
//    _serverPlatform = serverPlatform;
//    [[NSUserDefaults standardUserDefaults] setInteger:_serverPlatform forKey:@"serverPlatform"];
//    [self serverInit];
//}

//- (void)refreshUserInfo{
//    int tag = [self getConnectTag];
//    [self getUserInfoWithUid:self.uid tag:tag error:nil];
//    [self addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
//        if (jsonRet && !errorMsg) {
//            [[REngine shareInstance].userInfo setUserInfoByJsonDic:[jsonRet objectForKey:@"object"]];
//            [REngine shareInstance].userInfo = [REngine shareInstance].userInfo;
//        }
//        
//    } tag:tag];
//}

#pragma mark - Visitor
- (void)visitorLogin{
    _uid = nil;
    _account = nil;
    _userPassword = nil;
    [self removeAccount];
    _userInfo = [[RUserInfo alloc] init];
}
//- (BOOL)needUserLogin:(NSString *)message{
//    if (![self hasAccoutLoggedin]) {
//        if (message == nil) {
//            message = @"请登录";
//        }
//        RAlertView *alertView = [[RAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:@"取消" cancelBlock:^{
//        } okButtonTitle:@"登录" okBlock:^{
//            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
////            WelcomeViewController *welcomeVc = [[WelcomeViewController alloc] init];
////            welcomeVc.showBackButton = YES;
//            RNavigationController* navigationController = [[XENavigationController alloc] initWithRootViewController:welcomeVc];
//            navigationController.navigationBarHidden = YES;
//            [appDelegate.mainTabViewController.navigationController presentViewController:navigationController animated:YES completion:^{
//                
//            }];
//        }];
//        [alertView show];
//        return YES;
//    }
//    return NO;
//}

#pragma mark - request
//////////////////////
- (int)getConnectTag{
    return _connectTag++;
}

- (void)addOnAppServiceBlock:(onAppServiceBlock)block tag:(int)tag{
    [_onAppServiceBlockMap setObject:[block copy] forKey:[NSNumber numberWithInt:tag]];
}

- (void)removeOnAppServiceBlockForTag:(int)tag{
    [_onAppServiceBlockMap removeObjectForKey:[NSNumber numberWithInt:tag]];
}

- (onAppServiceBlock)getonAppServiceBlockByTag:(int)tag{
    return [_onAppServiceBlockMap objectForKey:[NSNumber numberWithInt:tag]];
}

- (void)addGetCacheTag:(int)tag{
    [_urlCacheTagMap setObject:@"" forKey:[NSNumber numberWithInt:tag]];
}

- (void)getCacheReponseDicForTag:(int)tag complete:(void(^)(NSDictionary* jsonRet))complete{
    NSString* urlString = [_urlCacheTagMap objectForKey:[NSNumber numberWithInt:tag]];
    [_urlCacheTagMap removeObjectForKey:[NSNumber numberWithInt:tag]];
    if (urlString == nil) {
        complete(nil);
        return;
    }
    if (urlString.length == 0) {
        complete(nil);
        return;
    }
    [self getCacheReponseDicForUrl:urlString complete:complete];
}

- (void)getCacheReponseDicForUrl:(NSString*)url complete:(void(^)(NSDictionary* jsonRet))complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [[self getCacheInstance] stringForKey:[RCommonUtils fileNameEncodedString:url]];
        NSDictionary* jsonRet = [response objectFromJSONString];
        ls_dispatch_main_sync_safe(^{
            //catch缓存异常，并删除该缓存
            @try {
                complete(jsonRet);
            }
            @catch (NSException *exception) {
                NSLog(@"getCacheReponseDicForUrl complete exception=%@", exception);
                [[self getCacheInstance] removeCacheForKey:[RCommonUtils fileNameEncodedString:url]];
            }
        });
    });
}

- (void)saveCacheWithString:(NSString*)str url:(NSString*)url {
    [[self getCacheInstance] setString:str forKey:[RCommonUtils fileNameEncodedString:url]];
}

- (void)clearAllCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self getCacheInstance] clearCache];
    });
}

- (unsigned long long)getUrlCacheSize {
    NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    cachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:_uid] copy];
    return [RCommonUtils getDirectorySizeForPath:cachesDirectory];
}

- (NSDictionary*)getRequestJsonWithUrl:(NSString*)url type:(int)type parameters:(NSDictionary *)params{
    return [self getRequestJsonWithUrl:url requestType:type serverType:1 parameters:params fileParam:nil];
}

- (NSDictionary*)getRequestJsonWithUrl:(NSString*)url requestType:(int)requestType serverType:(int)serverType parameters:(NSDictionary *)params fileParam:(NSString*)fileParam{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:url forKey:@"url"];
    [dic setObject:[NSNumber numberWithInt:requestType]  forKey:@"requestType"];
    [dic setObject:[NSNumber numberWithInt:serverType] forKey:@"serverType"];
    //    if ([params count] > 0) {
    //        [dic setObject:[URLHelper getURL:nil queryParameters:params prefixed:NO] forKey:@"params"];
    //    }
    //    if (fileParam) {
    //        [dic setObject:fileParam forKey:@"fileParam"];
    //    }
    if (params) {
        [dic setObject:params forKey:@"params"];
    }
    return dic;
}

- (BOOL)reDirectXECommonWithFormatDic:(NSDictionary *)dic withData:(NSArray *)dataArray withTag:(int)tag withTimeout:(NSTimeInterval)timeout error:(NSError *)errPtr {
    
    NSString* url = [dic objectForKey:@"url"];
    NSString* method = @"POST";
    if ([[dic objectForKey:@"requestType"] integerValue] == 1) {
        method = @"GET";
    }
    
    NSDictionary *params = [dic objectForKey:@"params"];
    
    if ([method isEqualToString:@"GET"]) {
        NSString* fullUrl = url;
        if (params) {
            NSString *param = [URLHelper getURL:nil queryParameters:params prefixed:NO];
            fullUrl = [NSString stringWithFormat:@"%@?%@", fullUrl, param];
        }
        NSLog(@"getFullUrl=%@",fullUrl);
        if ([_urlCacheTagMap objectForKey:[NSNumber numberWithInt:tag]]) {
            [_urlCacheTagMap setObject:fullUrl forKey:[NSNumber numberWithInt:tag]];
            [_needCacheUrls addObject:fullUrl];
            return YES;
        }
        [_urlTagMap setObject:fullUrl forKey:[NSNumber numberWithInteger:tag]];
        [QHQnetworkingTool getWithURL:fullUrl params:nil success:^(id response) {
            NSLog(@"getFullUrl===========%@ response%@",fullUrl,response);
            [self onResponse:response withTag:tag withError:errPtr];
        } failure:^(NSError *error) {
            [self onResponse:nil withTag:tag withError:error];
        }];
        return YES;
    }else {
        NSString* fullUrl = url;
//        if (params) {
//            NSString *param = [URLHelper getURL:nil queryParameters:params prefixed:NO];
//            fullUrl = [NSString stringWithFormat:@"%@?%@", fullUrl, param];
//        }
        NSLog(@"postFullUrl=%@",fullUrl);
        if (dataArray) {
            [QHQnetworkingTool postWithURL:fullUrl params:nil formDataArray:dataArray success:^(id response) {
                NSLog(@"postFullUrl===========%@ response%@",fullUrl,response);
                [self onResponse:response withTag:tag withError:errPtr];
            } failure:^(NSError *error) {
                [self onResponse:nil withTag:tag withError:error];
            }];
        }else{
            [QHQnetworkingTool postWithURL:fullUrl params:params success:^(id response) {
                NSLog(@"postFullUrl===========%@ response%@",fullUrl,response);
                [self onResponse:response withTag:tag withError:errPtr];
            } failure:^(NSError *error) {
                [self onResponse:nil withTag:tag withError:error];
            }];
        }
        return YES;
    }
    
    NSError* err = nil;
    if (errPtr) {
        err = errPtr;
    }
    onAppServiceBlock block = [self getonAppServiceBlockByTag:tag];
    if (block) {
        [self removeOnAppServiceBlockForTag:tag];
        block(tag, nil, err);
    }
    
    return NO;
}

- (void)onResponse:(id)jsonRet withTag:(int)tag withError:(NSError *)errPtr
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        BOOL timeout = NO;
        if (!jsonRet) {
            timeout = YES;
        }
        if (jsonRet && !errPtr) {
            NSString* fullUrl = [_urlTagMap objectForKey:[NSNumber numberWithInt:tag]];
            if (fullUrl) {
                //有错误的内容不缓存
                if ([_needCacheUrls containsObject:fullUrl] && ![REngine getErrorMsgWithReponseDic:jsonRet]) {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonRet options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [[self getCacheInstance] setString:jsonString forKey:[RCommonUtils fileNameEncodedString:fullUrl]];
                    NSLog(@"=======================%@",jsonRet);
                }
            }
        }
        
        [_urlTagMap removeObjectForKey:[NSNumber numberWithInt:tag]];
        
        onAppServiceBlock block = [self getonAppServiceBlockByTag:tag];
        if (block) {
            [self removeOnAppServiceBlockForTag:tag];
            if (timeout) {
                block(tag, nil, [NSError errorWithDomain:@"timeout" code:408 userInfo:nil]);
            }else{
                block(tag, jsonRet, errPtr);
            }
        }
    });
}

#pragma mark -register and login
- (BOOL)registerWithPhone:(NSString*)phone password:(NSString*)password type:(NSString *)userType name:(NSString *)contactName tag:(int)tag
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:phone forKey:@"userName"];
    [params setObject:password forKey:@"password"];
    [params setObject:userType forKey:@"userType"];
    [params setObject:contactName forKey:@"contactName"];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/saveUser",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

- (BOOL)loginWithPhone:(NSString*)phone password:(NSString*)password tag:(int)tag
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:phone forKey:@"userName"];
    [params setObject:password forKey:@"password"];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/userLogin",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

- (BOOL)getSmsCodeWithPhone:(NSString *)phone tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:phone forKey:@"phoneNum"];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/sendSMS",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

#pragma mark - home
//获取房源信息
- (BOOL)getHouseInfoWithNum:(NSUInteger)pagenum count:(NSUInteger)count uid:(NSString *)uid status:(int)status tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/getHouseListData",API_URL] type:1 parameters:params];
    if (pagenum) {
        [params setObject:[NSNumber numberWithInteger:pagenum] forKey:@"page"];
    }
    if (uid) {
        [params setObject:uid forKey:@"userId"];
//        [params setObject:[NSNumber numberWithInt:status] forKey:@"qStatus"];
    }
    [params setObject:[NSNumber numberWithInteger:count] forKey:@"rows"];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//筛选房源列表信息
- (BOOL)getHouseListWithNum:(NSUInteger)pagenum count:(NSUInteger)count qRoomAreaMin:(NSString *)aMin qRoomAreaMax:(NSString *)aMax qPriceMin:(NSString *)pMin qPriceMax:(NSString *)pMax qCanCooking:(NSString *)cooking qHaveFurniture:(NSString *)furniture qDirection:(NSString *)dire tag:(int)tag
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/getHouseListData",API_URL] type:1 parameters:params];
    [params setObject:[NSNumber numberWithInteger:pagenum] forKey:@"page"];
    [params setObject:[NSNumber numberWithInteger:count] forKey:@"rows"];
    if (aMin) {
        [params setObject:aMin forKey:@"qRoomAreaMin"];
    }
    if (aMax) {
        [params setObject:aMax forKey:@"qRoomAreaMax"];
    }
    if (pMin) {
        [params setObject:pMin forKey:@"qPriceMin"];
    }
    if (pMax) {
        [params setObject:pMax forKey:@"qPriceMax"];
    }
    if (cooking) {
        [params setObject:cooking forKey:@"qCanCooking"];
    }
    if (furniture) {
        [params setObject:furniture forKey:@"qHaveFurniture"];
    }
    if (dire) {
        [params setObject:dire forKey:@"qDirection"];
    }
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//获取房源详情
- (BOOL)getHouseDetailWithUid:(NSString *)uid houseId:(NSString *)houseId tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/getHouseDetailData",API_URL] type:1 parameters:params];
    [params setObject:houseId forKey:@"houseId"];
    if (uid) {
        [params setObject:uid forKey:@"userId"];
    }
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

- (BOOL)getAppNewVersionWithAppType:(int)appType version:(NSInteger)version tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:appType] forKey:@"appType"];
    [params setObject:[NSNumber numberWithInteger:version] forKey:@"version"];
    
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/checkUpdate",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

- (BOOL)getCollectHouseListWithNum:(NSUInteger)pagenum count:(NSUInteger)count uid:(NSString *)uid  queryType:(int)queryType tag:(int)tag{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if (pagenum) {
        [params setObject:[NSNumber numberWithInteger:pagenum] forKey:@"page"];
    }
    [params setObject:[NSNumber numberWithInteger:count] forKey:@"rows"];
    
    [params setObject:[NSNumber numberWithInt:queryType] forKey:@"queryType"];
    
    if (uid) {
        [params setObject:uid forKey:@"userId"];
    }
    
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/getRelationHouse",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
    
}

- (BOOL)getHouseRecordListWithNum:(NSUInteger)pagenum count:(NSUInteger)count uid:(NSString *)uid  queryType:(int)queryType tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if (pagenum) {
        [params setObject:[NSNumber numberWithInteger:pagenum] forKey:@"page"];
    }
    [params setObject:[NSNumber numberWithInteger:count] forKey:@"rows"];
    
    [params setObject:[NSNumber numberWithInt:queryType] forKey:@"queryType"];
    
    if (uid) {
        [params setObject:uid forKey:@"userId"];
    }
    
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/getDealHouse",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

- (BOOL)getMineCountDataWithUid:(NSString *)uid queryType:(int)queryType tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [params setObject:[NSNumber numberWithInt:queryType] forKey:@"queryType"];
    
    if (uid) {
        [params setObject:uid forKey:@"userId"];
    }
    
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/countData",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}
- (BOOL)markHasBeenRentWithHouseId:(NSString *)houseId tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if (houseId) {
        [params setObject:houseId forKey:@"houseId"];
    }
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/delHouse",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}
- (BOOL)resetPublishWithHouseId:(NSString *)houseId tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if (houseId) {
        [params setObject:houseId forKey:@"houseId"];
    }
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/resendHouse",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//收藏/已电话联系房东操作
- (BOOL)collectHouseWithUid:(NSString *)uid houseId:(NSString *)hid type:(NSString *)type tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:@"userId"];
    [params setObject:hid forKey:@"houseId"];
    [params setObject:type forKey:@"type"];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/collectHouse",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//取消收藏
- (BOOL)cancelCollectHouseWithUid:(NSString *)uid houseId:(NSString *)hid tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:@"userId"];
    [params setObject:hid forKey:@"houseId"];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/cancelRelation",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//图片上传
- (BOOL)updateImageWithData:(NSArray *)data tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/imgUpload",API_URL] type:2 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:data withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//发布房源
- (BOOL)publicHouseWithUid:(NSString *)uid title:(NSString *)title description:(NSString *)desc typeA:(NSString *)typeA typeB:(NSString *)typeB typeC:(NSString *)typeC floor:(NSString *)floor floorTop:(NSString *)floorTop area:(NSString *)area direction:(NSString *)direction fitment:(int)fitment price:(NSString *)price payType:(int)payType address:(NSString *)address imgs:(NSString *)imgIds canCooking:(int)canCooking haveFurniture:(int)haveFurniture tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if (uid) {
        [params setObject:uid forKey:@"ownerId"];
    }
    if (title) {
        [params setObject:title forKey:@"title"];
    }
    if (desc) {
        [params setObject:desc forKey:@"description"];
    }
    if (typeA) {
        [params setObject:typeA forKey:@"typeA"];
    }
    if (typeB) {
        [params setObject:typeB forKey:@"typeB"];
    }
    if (typeC) {
        [params setObject:typeC forKey:@"typeC"];
    }
    if (floor) {
        [params setObject:floor forKey:@"floor"];
    }
    if (floorTop) {
        [params setObject:floorTop forKey:@"floorTop"];
    }
    if (area) {
        [params setObject:area forKey:@"area"];
    }
    if (direction) {
        [params setObject:direction forKey:@"direction"];
    }
    if (fitment) {
        [params setObject:[NSNumber numberWithInt:fitment] forKey:@"fitment"];
    }
    if (price) {
        [params setObject:price forKey:@"price"];
    }
    if (payType) {
        [params setObject:[NSNumber numberWithInt:payType] forKey:@"payType"];
    }
    if (address) {
        [params setObject:address forKey:@"address"];
    }
    if (imgIds) {
        [params setObject:imgIds forKey:@"imgIds"];
    }
    if (canCooking) {
        [params setObject:[NSNumber numberWithInt:canCooking] forKey:@"canCooking"];
    }
    if (haveFurniture) {
        [params setObject:[NSNumber numberWithInt:haveFurniture] forKey:@"haveFurniture"];
    }
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/saveHouse",API_URL] type:2 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//租客确认房源
- (BOOL)comfirmHouseWithUid:(NSString *)uid houseId:(NSString *)houseId tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:uid forKey:@"userId"];
    [params setObject:houseId forKey:@"houseId"];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/confirmHouse",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

//房东确认租出
- (BOOL)checkHouseWithHouseId:(NSString *)houseId tag:(int)tag{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:houseId forKey:@"houseId"];
    NSDictionary* formatDic = [self getRequestJsonWithUrl:[NSString stringWithFormat:@"%@/houseRenting/houseApi/checkHouse",API_URL] type:1 parameters:params];
    return [self reDirectXECommonWithFormatDic:formatDic withData:nil withTag:tag withTimeout:CONNECT_TIMEOUT error:nil];
}

@end
