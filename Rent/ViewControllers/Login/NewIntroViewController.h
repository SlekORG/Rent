//
//  NewIntroViewController.h
//  Xiaoer
//
//  Created by KID on 15/1/6.
//
//

#import "RSuperViewController.h"

@class NewIntroViewController;
@protocol NewIntroViewControllerDelegate <NSObject>
- (void)introduceVcFinish:(NewIntroViewController*)vc;
@end

@interface NewIntroViewController : RSuperViewController
@property (nonatomic, assign) id<NewIntroViewControllerDelegate> delegate;
@end
