//
//  RUIKitMacro.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#ifndef Rent_RUIKitMacro_h
#define Rent_RUIKitMacro_h

#define STAUTTAR_DEFAULT_HEIGHT 20
#define R_Default_TitleNavBar_Height 44

//将16进制颜色转换为uicolor
#define UIColorToRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//rgbColor
#define UIColorRGB(r,g,b)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

#endif
