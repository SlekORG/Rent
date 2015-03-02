//
//  HomeViewCell.m
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "HomeViewCell.h"
#import "RCommonUtils.h"
#import "RUIUtils.h"
#import "UIImageView+WebCache.h"

@implementation HomeViewCell

+ (float)heightForHouseInfo:(RHouseInfo *)houseInfo{
    //    NSString* topicText = topicInfo.title;
    //    if (!topicText) {
    //        topicText = @"";
    //    }
    //    CGSize topicTextSize = [XECommonUtils sizeWithText:topicText font:[UIFont systemFontOfSize:15] width:SCREEN_WIDTH-11-26];
    //
    //    if (topicTextSize.height < 16) {
    //        topicTextSize.height = 16;
    //    }
    //    float height = topicTextSize.height;
    //    height += 35;
    //    return height;
    return 70;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setHouseInfo:(RHouseInfo *)houseInfo{
    _houseInfo = houseInfo;
    self.houseTitleLabel.text = houseInfo.title;
    self.housePriceLabel.text = [NSString stringWithFormat:@"%@/月",houseInfo.price];
    self.houseDesLabel.text = [NSString stringWithFormat:@"%@室%@厅%@卫",houseInfo.typeA,houseInfo.typeB,houseInfo.typeC];
    self.houseAddressLabel.text = houseInfo.statusName;
    
    if (![houseInfo.picUrl isEqual:[NSNull null]]) {
        [self.houseImageView sd_setImageWithURL:houseInfo.picUrl placeholderImage:[UIImage imageNamed:@"house_load_icon"]];
    }else{
        [self.houseImageView sd_setImageWithURL:nil];
        [self.houseImageView setImage:[UIImage imageNamed:@"house_load_icon"]];
    }
}

@end
