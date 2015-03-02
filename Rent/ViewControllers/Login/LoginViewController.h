//
//  LoginViewController.h
//  Rent
//
//  Created by 许 磊 on 15/3/3.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "SuperMainViewController.h"

typedef void(^BackActionCallBack)(BOOL isBack);

@interface LoginViewController : SuperMainViewController

@property (nonatomic, assign) BOOL showBackButton;
@property (nonatomic, strong) BackActionCallBack backActionCallBack;

@end
