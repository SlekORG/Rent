//
//  RSettingConfig.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSettingConfig : NSObject

//系统相机闪光灯状态
@property (nonatomic, assign) int systemCameraFlashStatus;

+(RSettingConfig *)staticInstance;

+ (void)logout;
- (void)login;

-(void)saveSettingCfg;
-(void)setUserCfg:(NSDictionary*)dict;

+(void)saveEnterVersion;
+(BOOL)isFirstEnterVersion;

+(void)saveEnterUsr;

@end
