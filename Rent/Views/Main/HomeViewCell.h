//
//  HomeViewCell.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHouseInfo.h"

@interface HomeViewCell : UITableViewCell

@property (strong, nonatomic) RHouseInfo *houseInfo;

@property (strong, nonatomic) IBOutlet UIImageView *houseImageView;
@property (strong, nonatomic) IBOutlet UILabel *houseTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *houseAddressLabel;
@property (strong, nonatomic) IBOutlet UILabel *houseDesLabel;
@property (strong, nonatomic) IBOutlet UILabel *housePriceLabel;

+ (float)heightForHouseInfo:(RHouseInfo *)houseInfo;


@end
