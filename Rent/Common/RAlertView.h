//
//  RAlertView.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAlertView : UIAlertView

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle cancelBlock:(void(^)(void))cancelBlock;
/*
 Currently just accepting two buttons and two blocks.
 */
- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle cancelBlock:(void(^)(void))cancelBlock okButtonTitle:(NSString*)okButtonTitle okBlock:(void(^)(void))okBlock;

//纯提示
-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitile;


@end
