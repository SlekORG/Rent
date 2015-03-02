//
//  RAlertView.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "RAlertView.h"

@interface RAlertView()<UIAlertViewDelegate>
@property (nonatomic, strong) void(^okBlock)(void);
@property (nonatomic, strong) void(^cancelBlock)(void);
@end


@implementation RAlertView

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle cancelBlock:(void(^)(void))cancelBlock
{
    return [self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle cancelBlock:cancelBlock okButtonTitle:nil okBlock:nil];
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle cancelBlock:(void(^)(void))cancelBlock okButtonTitle:(NSString*)okButtonTitle okBlock:(void(^)(void))okBlock
{
    //ios 8 如果title 为 nil 显示特别靠上
    if (!title) {
        title = @"";
    }
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles: okButtonTitle, nil];
    if (self)
    {
        self.cancelBlock = cancelBlock;
        self.okBlock = okBlock;
    }
    return self;
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitile
{
    
    //ios 8 如果title 为 nil 显示特别靠上
    if (!title) {
        title = @"";
    }
    
    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitile otherButtonTitles:nil, nil];
    if (self) {
        
    }
    
    return self;
}

-(void)dealloc
{
    NSLog(@"alertView dealloc");
}

#pragma mark - AlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //The receiver is automatically dismissed after this method is invoked.
    
    //    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    //    switch (buttonIndex)
    //    {
    //        case 0:
    //            if (self.cancelBlock) {
    //                self.cancelBlock();
    //            }
    //            break;
    //        case 1:
    //            if (self.okBlock) {
    //                self.okBlock();
    //            }
    //            break;
    //        default:
    //            break;
    //    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (buttonIndex)
    {
        case 0:
            if (self.cancelBlock) {
                self.cancelBlock();
            }
            break;
        case 1:
            if (self.okBlock) {
                self.okBlock();
            }
            break;
        default:
            break;
    }
    
}

@end
