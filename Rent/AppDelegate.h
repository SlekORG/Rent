//
//  AppDelegate.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readwrite, nonatomic) RTabBarViewController* mainTabViewController;
@property (strong, nonatomic) UIMenuController *appMenu;

- (void)signIn;
- (void)signOut;

@end

