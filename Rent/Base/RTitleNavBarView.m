//
//  RTitleNavBarView.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "RTitleNavBarView.h"

@interface RTitleNavBarView ()

@property (nonatomic, weak) id owner;
//titleLabel
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
//background image
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

@end

@implementation RTitleNavBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init:(id)owner{
    self = [[[NSBundle mainBundle] loadNibNamed:@"RTitleNavBarView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        //load view
        _owner = owner;
        self.backgroundImageView.backgroundColor = SKIN_COLOR;
    }
    return self;
}

-(id) setTitle:(NSString *) title
{
    _titleLabel.text = title;
    return _titleLabel;
}
-(id) setTitle:(NSString *) title font:(UIFont *) font;
{
    _titleLabel.text = title;
    _titleLabel.font = font;
    return _titleLabel;
}


@end
