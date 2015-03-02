//
//  RTabBarViewController.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTabBarView.h"

#define TAB_INDEX_MINE 3
#define TAB_INDEX_CHAT 2
#define TAB_INDEX_EVALUATION 1
#define TAB_INDEX_MAINPAGE 0

@protocol RTabBarControllerDelegate;

@interface RTabBarViewController : UIViewController

@property (nonatomic, assign) id <RTabBarControllerDelegate> delegate;

@property (nonatomic, retain) RTabBarView *tabBar;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property(nonatomic, assign) UInt32 initialIndex;

/*
 * -1表示有标示但不知具体数目，只显示红点
 */
- (void)setBadge:(int)badgeNum forIndex:(NSUInteger)index;
@end

@protocol RTabBarControllerDelegate <NSObject>
@optional
-(BOOL) tabBarController:(RTabBarViewController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
-(void) tabBarController:(RTabBarViewController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end

//viewControllers可以继承的协议
@protocol RTabBarControllerSubVcProtocol<NSObject>

@optional
//已经选中的情况再次选中
- (void)tabBarController:(RTabBarViewController *)tabBarController reSelectVc:(UIViewController *)viewController;

@end

/*!
 @category UIViewController (RTabBarControllerItem)
 @abstract
 */
@interface UIViewController (RTabBarControllerItem)

@property (nonatomic, retain) RTabBarViewController *tabController;

@end
