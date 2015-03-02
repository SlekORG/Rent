//
//  HouseFilterViewController.m
//  Rent
//
//  Created by KID on 15/3/2.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "HouseFilterViewController.h"
#import "REngine.h"
#import "XEProgressHUD.h"
#import "RAlertView.h"
#import "RHouseInfo.h"

#define Tag_Price_One     101
#define Tag_Price_Two     102
#define Tag_Price_three   103
#define Tag_Price_Four    104
#define Tag_Price_Five    105
#define Tag_Price_Six     106
#define Tag_Area_One      201
#define Tag_Area_Two      202
#define Tag_Area_three    203
#define Tag_Area_Four     204
#define Tag_Cooking_One   301
#define Tag_Furniture_Two 302

@interface HouseFilterViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>{
    NSString *_maxRoomArea;
    NSString *_minRoomArea;
    NSString *_maxPrice;
    NSString *_minPrice;
    NSString *_cooking;
    NSString *_furniture;
    NSString *_directionStr;
    BOOL bCooking;
    BOOL bFurniture;
    NSArray *_pickerArray;
    NSArray *_direArray;
}

@property (strong, nonatomic) NSMutableArray *housesArray;
@property (strong, nonatomic) IBOutlet UIButton *cookingBtn;
@property (strong, nonatomic) IBOutlet UIButton *furnitureBtn;
@property (strong, nonatomic) IBOutlet UIButton *directionBtn;
@property (strong, nonatomic) IBOutlet UIView *floatView;
@property (strong, nonatomic) IBOutlet UILabel *directionLabel;

@end

@implementation HouseFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect frame = _floatView.frame;
    frame.origin.y = self.view.bounds.size.height;
    _floatView.frame = frame;
    _directionStr = @"1";
    _pickerArray = [NSArray arrayWithObjects:@"朝东",@"朝南",@"朝西",@"朝北",@"南西",@"东南",@"西北",@"东北", nil];
    _direArray = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"房源筛选"];
}

- (IBAction)confirmAction:(id)sender {
    __weak HouseFilterViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    
    [[REngine shareInstance] getHouseListWithNum:1 count:10 qRoomAreaMin:_minRoomArea qRoomAreaMax:_maxRoomArea qPriceMin:_minPrice qPriceMax:_maxPrice qCanCooking:_cooking qHaveFurniture:_furniture qDirection:_directionStr tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSLog(@"====================%@",jsonRet);
        weakSelf.housesArray = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"rows"];
        for (NSDictionary *dic in object) {
            RHouseInfo *houseInfo = [[RHouseInfo alloc] init];
            [houseInfo setHouseInfoByDic:dic];
            [weakSelf.housesArray addObject:houseInfo];
        }
        [self.navigationController popViewControllerAnimated:YES];
        if (_housesFilterCallBack) {
            _housesFilterCallBack(weakSelf.housesArray);
        }
    }tag:tag];
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)priceFliterAction:(id)sender {
    UIButton *btn = sender;
    if(btn.tag == Tag_Price_One){
        _minPrice = @"0";
        _maxPrice = @"600";
    }else if (btn.tag == Tag_Price_Two){
        _minPrice = @"600";
        _maxPrice = @"800";
    }else if (btn.tag == Tag_Price_three){
        _minPrice = @"800";
        _maxPrice = @"1000";
    }else if (btn.tag == Tag_Price_Four){
        _minPrice = @"1000";
        _maxPrice = @"1500";
    }else if (btn.tag == Tag_Price_Five){
        _minPrice = @"1500";
        _maxPrice = @"2000";
    }else if (btn.tag == Tag_Price_Six){
        _minPrice = @"2000";
        _maxPrice = @"99999";
    }
}

- (IBAction)areaFliterAction:(id)sender {
    UIButton *btn = sender;
    if(btn.tag == Tag_Area_One){
        _minRoomArea = @"1";
        _maxRoomArea = @"10";
    }else if (btn.tag == Tag_Area_Two){
        _minRoomArea = @"10";
        _maxRoomArea = @"15";
    }else if (btn.tag == Tag_Area_three){
        _minRoomArea = @"15";
        _maxRoomArea = @"20";
    }else if (btn.tag == Tag_Area_Four){
        _minRoomArea = @"20";
        _maxRoomArea = @"99999";
    }
}

- (IBAction)direFliterAction:(id)sender {
    if (_floatView.superview == self.view) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = _floatView.frame;
            rect.origin.y = self.view.frame.size.height;
            _floatView.frame = rect;
        } completion:^(BOOL finished) {
            [self.floatView removeFromSuperview];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = _floatView.frame;
            rect.origin.y = self.view.frame.size.height - _floatView.frame.size.height;
            _floatView.frame = rect;
            [self.view addSubview:_floatView];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (IBAction)moreFliterAction:(id)sender {
    UIButton *btn = sender;
    if (btn.tag == Tag_Cooking_One) {
        bCooking = !bCooking;
        if (bCooking) {
            _cooking = @"1";
            [self.cookingBtn setImage:[UIImage imageNamed:@"select_choose_icon"] forState:UIControlStateNormal];
        }else{
            _cooking = @"2";
            [self.cookingBtn setImage:[UIImage imageNamed:@"select_unchoose_icon"] forState:UIControlStateNormal];
        }
    }else if (btn.tag == Tag_Furniture_Two) {
        bFurniture = !bFurniture;
        if (bFurniture) {
            _furniture = @"1";
            [self.furnitureBtn setImage:[UIImage imageNamed:@"select_choose_icon"] forState:UIControlStateNormal];
        }else{
            _furniture = @"2";
            [self.furnitureBtn setImage:[UIImage imageNamed:@"select_unchoose_icon"] forState:UIControlStateNormal];
        }
    }
}

#pragma -UIPickerView代理

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_pickerArray objectAtIndex:row];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerArray.count;
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    [self.directionLabel setText:[_pickerArray objectAtIndex:row]];
    _directionStr = [_direArray objectAtIndex:row];
}

@end
