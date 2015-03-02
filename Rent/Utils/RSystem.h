//
//  RSystem.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#ifndef Rent_RSystem_h
#define Rent_RSystem_h

#import "RUIKitMacro.h"
#import "NSDictionary+ObjectForKey.h"

#define SINGLE_CELL_HEIGHT 44.f
#define SINGLE_HEADER_HEADER 6.f

#define R_IMAGE_COMPRESSION_QUALITY 0.4

#define SKIN_COLOR [UIColor colorWithRed:(1.0*0x1b/0xff) green:(1.0*0xb9/0xff) blue:(1.0*0xe8/0xff) alpha:1]

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// 自定义Log
#ifdef DEBUG
#define XELog(...) NSLog(__VA_ARGS__)
#else
#define XELog(...)
#endif

#endif
