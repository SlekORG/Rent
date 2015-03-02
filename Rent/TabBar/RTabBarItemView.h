//
//  RTabBarItemView.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTabBarItemViewProtocol;

@interface RTabBarItemView : UIView

@property (strong, nonatomic) IBOutlet UIButton *itemBtn;
@property (strong, nonatomic) IBOutlet UIImageView *itemIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bkImageView;

@property(nonatomic,assign) id<RTabBarItemViewProtocol> delegate;
@property(nonatomic,assign) bool selected;
@property(nonatomic,assign) int badgeNum;//0表示不显示badgeview，大于0展示数字badge，-1展示成红点

- (IBAction)itemTouchDown:(id)sender ;
@end

@protocol RTabBarItemViewProtocol <NSObject>
- (void)selectForItemView:(id)view;

@end
