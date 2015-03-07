//
//  LoginViewController.h
//  Rent
//
//  Created by 许 磊 on 15/3/3.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "SuperMainViewController.h"

typedef enum loginType_{
    VcType_Register = 0,   //注册
    VcType_Login,          //登录
}loginType;

typedef void(^BackActionCallBack)(BOOL isBack);

@interface LoginViewController : SuperMainViewController

@property (nonatomic, assign) loginType vcType;
@property (nonatomic, assign) BOOL showBackButton;
@property (nonatomic, strong) BackActionCallBack backActionCallBack;

@end
