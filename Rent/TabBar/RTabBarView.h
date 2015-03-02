//
//  RTabBarView.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTabBarItemView.h"

@protocol RTabBarDelegate;
@interface RTabBarView : UIView

@property(nonatomic, assign) id<RTabBarDelegate> delegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) RTabBarItemView *selectedTabBarItem;
@property(nonatomic, assign) UInt32 initialIndex;
@property(nonatomic, assign) BOOL simulateSelected;
- (void)selectIndex:(NSUInteger)anIndex;
@end

@protocol RTabBarDelegate <NSObject>

@optional
-(void) tabBar:(RTabBarView *)aTabBar didSelectTabAtIndex:(NSUInteger)anIndex;
@end

