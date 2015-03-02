//
//  RSuperViewController.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBaseSuperViewController.h"
#import "RCommonVcTransition.h"

@interface RSuperViewController : RBaseSuperViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) RCommonVcTransition *interactivePopTransition;
@property (nonatomic, assign) BOOL disablePan;

- (IBAction)backAction:(id)sender;

@end
