//
//  AppDelegate.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "AppDelegate.h"
#import "REngine.h"
#import "RSettingConfig.h"
#import "HomeViewController.h"
#import "MineViewController.h"
#import "MoreViewController.h"
#import "RNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    application.statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _appMenu = [[UIMenuController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    
//    if ([[REngine shareInstance] hasAccoutLoggedin] || ![REngine shareInstance].firstLogin) {
//        if ([RSettingConfig isFirstEnterVersion]) {
//            [self showNewIntro];
//        } else {
//            [self signIn];
//        }
//    }else{
//        NSLog(@"signOut for accout miss");
//        [self signOut];
//    }
    [self signIn];
    [self.window makeKeyAndVisible];
    
    return YES;
}

//新手引导
-(void)showNewIntro{
//    NewIntroViewController *introVc = [[NewIntroViewController alloc] init];
//    introVc.delegate = self;
//    self.window.rootViewController = introVc;
}

- (void)signIn{
    NSLog(@"signIn");
    
    if ([[REngine shareInstance] hasAccoutLoggedin]) {
        [REngine shareInstance].bVisitor = NO;
    }else {
        [REngine shareInstance].bVisitor = YES;
    }
    
//    if([RSettingConfig isFirstEnterVersion]){
//        [self showNewIntro];
//        return;
//    }
//    
//    [RSettingConfig saveEnterUsr];
    
    RTabBarViewController* tabViewController = [[RTabBarViewController alloc] init];
    tabViewController.viewControllers = [NSArray arrayWithObjects:
                                         [[HomeViewController alloc] init],
                                         [[MineViewController alloc] init],
                                         [[MoreViewController alloc] init],
                                         nil];
    
    _mainTabViewController = tabViewController;
    
    RNavigationController* tabNavVc = [[RNavigationController alloc] initWithRootViewController:tabViewController];
    tabNavVc.navigationBarHidden = YES;
    
    if (![REngine shareInstance].firstLogin) {
        _mainTabViewController.initialIndex = 0;
    }
    
    self.window.rootViewController = tabNavVc;
    
//    [self checkVersion];
    
}

- (void)signOut{
    NSLog(@"signOut");
    
    if([RSettingConfig isFirstEnterVersion]){
        [self showNewIntro];
        return;
    }
    
//    WelcomeViewController* welcomeViewController = [[WelcomeViewController alloc] init];
//    XENavigationController* navigationController = [[XENavigationController alloc] initWithRootViewController:welcomeViewController];
//    navigationController.navigationBarHidden = YES;
//    self.window.rootViewController = navigationController;
//    
//    _mainTabViewController = nil;
    
    [[REngine shareInstance] logout];
    //    [XEEngine shareInstance].firstLogin = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
