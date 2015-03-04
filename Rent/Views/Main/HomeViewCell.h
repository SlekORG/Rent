//
//  HomeViewCell.h
//  Rent
//
//  Created by 许 磊 on 15/3/1.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHouseInfo.h"

typedef enum cellType_{
    cellType_Normal = 0,     //我的收藏
    cellType_contact,        //已联系房东
    cellType_Affirm,         //待确认房源
}cellType;

@protocol HomeCellDelegate<NSObject>

@optional
- (void)didTouchCellBtnWithHouseInfo:(RHouseInfo *)houseInfo;

@end

@interface HomeViewCell : UITableViewCell

@property (strong, nonatomic) RHouseInfo *houseInfo;

@property (strong, nonatomic) IBOutlet UIImageView *houseImageView;
@property (strong, nonatomic) IBOutlet UILabel *houseTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *houseAddressLabel;
@property (strong, nonatomic) IBOutlet UILabel *houseDesLabel;
@property (strong, nonatomic) IBOutlet UILabel *housePriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *hideButton;

@property (nonatomic, assign) cellType type;
@property (assign, nonatomic) id <HomeCellDelegate> delegate;

+ (float)heightForHouseInfo:(RHouseInfo *)houseInfo;

@end
