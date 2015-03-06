//
//  PublicHouseViewController.m
//  Rent
//
//  Created by KID on 15/3/4.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "PublicHouseViewController.h"
#import "QHQnetworkingTool.h"
#import "AVCamUtilities.h"
#import "RImagePickerController.h"
#import "XEProgressHUD.h"
#import "REngine.h"
#import "UIImage+ProportionalFill.h"
#import "UIImage+Resize.h"
#import "GMGridViewLayoutStrategies.h"
#import "GMGridViewCell+Extended.h"
#import "XEActionSheet.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

#define MAX_IMAGES_NUM    3
#define ONE_IMAGE_HEIGHT  70
#define item_spacing  4

#define Tag_Cooking_One   301
#define Tag_Furniture_Two 302

#define Tag_direction_check 401
#define Tag_Fitment_check   402
#define Tag_PayType_check   403

@interface PublicHouseViewController ()<UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GMGridViewDataSource, GMGridViewActionDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UIScrollViewDelegate>{
    CGRect _oldRect;
    BOOL bCooking;
    BOOL bFurniture;
    BOOL bDirection;
    BOOL bFitment;
    BOOL bPayType;
    int  cooking;
    int  furniture;
    int  direction;
    int  fitment;
    int  payType;
    NSArray *_direTextArray;
    NSArray *_direArray;
    NSArray *_fitmentTextArray;
    NSArray *_fitmentArray;
    NSArray *_payTextArray;
    NSArray *_payArray;
    NSInteger checkType;
}

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *imgIds;

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextView *descTextView;
@property (strong, nonatomic) IBOutlet UITextField *typeaField;
@property (strong, nonatomic) IBOutlet UITextField *typebField;
@property (strong, nonatomic) IBOutlet UITextField *typecField;
@property (strong, nonatomic) IBOutlet UITextField *floorField;
@property (strong, nonatomic) IBOutlet UITextField *floorTopField;
@property (strong, nonatomic) IBOutlet UITextField *areaField;
@property (strong, nonatomic) IBOutlet UITextField *priceField;
@property (strong, nonatomic) IBOutlet UITextField *addressField;
@property (strong, nonatomic) IBOutlet UIButton *cookingBtn;
@property (strong, nonatomic) IBOutlet UIButton *furnitureBtn;
@property (strong, nonatomic) IBOutlet UIButton *direButton;
@property (strong, nonatomic) IBOutlet UILabel *direLabel;
@property (strong, nonatomic) IBOutlet UIButton *fitmentButton;
@property (strong, nonatomic) IBOutlet UILabel *fitmentLabel;
@property (strong, nonatomic) IBOutlet UIButton *payTypeButton;
@property (strong, nonatomic) IBOutlet UILabel *payTypeLabel;

@property (strong, nonatomic) IBOutlet UIView *inputContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *inputBgView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet GMGridView *imagesGridView;

@property (nonatomic, weak) UIView *Pickermask;

@end

@implementation PublicHouseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.inputBgView.image = [[UIImage imageNamed:@"verify_commit_bg"] stretchableImageWithLeftCapWidth:30 topCapHeight:22];
    
    NSInteger spacing = 7;
    _imagesGridView.backgroundColor = [UIColor clearColor];
    _imagesGridView.style = GMGridViewStyleSwap;
    _imagesGridView.itemSpacing = spacing;
    _imagesGridView.minEdgeInsets = UIEdgeInsetsMake(7, 10, 0, 0);
    _imagesGridView.centerGrid = NO;
    _imagesGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    _imagesGridView.actionDelegate = self;
    _imagesGridView.showsHorizontalScrollIndicator = NO;
    _imagesGridView.showsVerticalScrollIndicator = NO;
    _imagesGridView.scrollEnabled = NO;
    _imagesGridView.dataSource = self;
    _imagesGridView.enableEditOnLongPress = YES;
    _imagesGridView.disableEditOnEmptySpaceTap = YES;
    
    if (self.images == nil) {
        self.images = [[NSMutableArray alloc] init];
        self.imgIds = [[NSMutableArray alloc] init];
    }
    [self.imagesGridView reloadData];
    [self.mainScrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT*1.1)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _direTextArray = [NSArray arrayWithObjects:@"朝东",@"朝南",@"朝西",@"朝北",@"南西",@"东南",@"西北",@"东北",nil];
    _direArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8)];
    _fitmentTextArray = [NSArray arrayWithObjects:@"毛坯",@"简单装修",@"中等装修",@"精装修",@"豪华装修",nil];
    _fitmentArray = @[@(1),@(2),@(3),@(4),@(5)];
    _payTextArray = [NSArray arrayWithObjects:@"押一付一",@"押一付二",@"押一付三",@"押二付一",@"押二付二",@"押二付三",@"半年付",@"年付",@"面议",nil];
    _payArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"发布房源"];
    [self setRightButtonWithTitle:@"发布" selector:@selector(publicAction)];
}

-(void) keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    //    CGRect containerFrame = _toolbarContainerView.frame;
    //    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    //    UIView *supView = self.contentContainerView;
    //    CGRect supViewFrame = supView.frame;
    //    float gapHeight = keyboardBounds.size.height + _toolbarContainerView.frame.size.height - (self.view.bounds.size.height - supViewFrame.origin.y - supViewFrame.size.height);
    //    BOOL isMove = (gapHeight > 0 && !_titleTextFieldEditing);
    //    if (gapHeight > 0 && _oldRect.size.height == 0 && _oldRect.size.width == 0) {
    //        supViewFrame.origin.y -= gapHeight;
    //        _oldRect = supViewFrame;
    //    }
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
//    CGRect toolbarFrame = _toolbarContainerView.frame;
//    toolbarFrame.origin.y = self.view.bounds.size.height - keyboardBounds.size.height - toolbarFrame.size.height;
//    _toolbarContainerView.frame = toolbarFrame;
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
//    CGRect toolbarFrame = _toolbarContainerView.frame;
//    toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
//    _toolbarContainerView.frame = toolbarFrame;
    
    // commit animations
    [UIView commitAnimations];
}

- (NSInteger)numberOfGridItems {
    if (self.images.count < MAX_IMAGES_NUM) {
        return self.images.count + 1;
    }
    return self.images.count;
}

#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self numberOfGridItems];
    
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return CGSizeMake(ONE_IMAGE_HEIGHT, ONE_IMAGE_HEIGHT);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
//    if (!cell)
//    {
//        cell = [[GMGridViewCell alloc] init];
//        UIImageView* imageView = [[UIImageView alloc] init];
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        imageView.clipsToBounds = YES;
//        cell.contentView = imageView;
//        
//    }
//    UIImageView* imageView = (UIImageView* )cell.contentView;
//    imageView.image = _images[index];
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"17_blacklist_del.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -12);
        UIImageView* imageview = [[UIImageView alloc] init];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.clipsToBounds = YES;
        imageview.layer.masksToBounds = YES;
        cell.contentView = imageview;
    }
    
    UIImageView* imageiew = (UIImageView*)cell.contentView;
    if (index >= self.images.count) {
        imageiew.layer.shadowColor = [UIColor clearColor].CGColor;
        [imageiew sd_setImageWithURL:nil];
        [imageiew setImage:[UIImage imageNamed:@"house_add_icon"]];
    } else {
        imageiew.image = [_images objectAtIndex:index];
    }

    return cell;
}
#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
//    //    NSLog(@"Did tap at index %ld", position);
//    __weak PublicHouseViewController *weakSelf = self;
//    XEActionSheet *sheet = [[XEActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
//        if (buttonIndex == 1) {
//            return;
//        }
//        if (buttonIndex == 0) {
//            [weakSelf.images removeObjectAtIndex:position];
//            [weakSelf.imagesGridView reloadData];
//        }
//    }];
//    [sheet addButtonWithTitle:@"删除"];
//    sheet.destructiveButtonIndex = sheet.numberOfButtons - 1;
//    [sheet addButtonWithTitle:@"取消"];
//    sheet.cancelButtonIndex = sheet.numberOfButtons -1;
//    [sheet showInView:self.view];
    __weak PublicHouseViewController *weakSelf = self;
    XEActionSheet *sheet = [[XEActionSheet alloc] initWithTitle:@"选择上传图片" actionBlock:^(NSInteger buttonIndex) {
        if (2 == buttonIndex) {
            return;
        }
        
        [weakSelf doActionSheetClickedButtonAtIndex:buttonIndex];
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", @"拍一张", nil];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [sheet showInView:appDelegate.window];
}

-(void)doActionSheetClickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == buttonIndex ) {
        //检查设备是否有相机功能
        if (![AVCamUtilities userCameraIsUsable]) {
            [RUIUtils showAlertWithMsg:[RUIUtils documentOfCameraDenied]];
            return;
        }
        //判断ios7用户相机是否打开
        if (![AVCamUtilities userCaptureIsAuthorization]) {
            [RUIUtils showAlertWithMsg:[RUIUtils documentOfAVCaptureDenied]];
            return;
        }
    }
    
    RImagePickerController *picker = [[RImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self.navigationController presentViewController:picker animated:YES completion:NULL];//用self.navigationController弹出 相机 StatusBar才会隐藏
}

- (IBAction)moreFliterAction:(id)sender {
    UIButton *btn = sender;
    if (btn.tag == Tag_Cooking_One) {
        bCooking = !bCooking;
        if (bCooking) {
            cooking = 1;
            [self.cookingBtn setImage:[UIImage imageNamed:@"select_choose_icon"] forState:UIControlStateNormal];
        }else{
            cooking = 2;
            [self.cookingBtn setImage:[UIImage imageNamed:@"select_unchoose_icon"] forState:UIControlStateNormal];
        }
    }else if (btn.tag == Tag_Furniture_Two) {
        bFurniture = !bFurniture;
        if (bFurniture) {
            furniture = 1;
            [self.furnitureBtn setImage:[UIImage imageNamed:@"select_choose_icon"] forState:UIControlStateNormal];
        }else{
            furniture = 2;
            [self.furnitureBtn setImage:[UIImage imageNamed:@"select_unchoose_icon"] forState:UIControlStateNormal];
        }
    }
}

- (void)publicAction{
    if (_titleField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入标题信息"];
        return;
    }
    if(_descTextView.text.length == 0) {
        [XEProgressHUD lightAlert:@"请入描述信息"];
        return;
    }
    if (_typeaField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入当前房间为几室"];
        return;
    }
    if (_typebField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入当前房间为几厅"];
        return;
    }
    if (_typecField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入当前房间为几卫"];
        return;
    }
    if (_floorField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入当前房间处在几层"];
        return;
    }
    if (_floorTopField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入当前房间总共层数"];
        return;
    }
    if (_areaField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入当前房间面积"];
        return;
    }
    if (_priceField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入当前房间租金"];
        return;
    }
    if (_addressField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入具体地址信息"];
        return;
    }
    if (!bDirection) {
        [XEProgressHUD lightAlert:@"请选择房间朝向"];
        return;
    }
    if (!bFitment) {
        [XEProgressHUD lightAlert:@"请选择装修类型"];
        return;
    }
    if (!bPayType) {
        [XEProgressHUD lightAlert:@"请选择支付形式"];
        return;
    }
    [self doforEndEdit];
    NSString *imgs = nil;
    if (self.imgIds.count > 0) {
        imgs = [RCommonUtils stringSplitWithCommaForIds:self.imgIds];
    }
    [XEProgressHUD AlertLoading:@"发送中..." At:self.view];
    __weak PublicHouseViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] publicHouseWithUid:[REngine shareInstance].uid title:_titleField.text description:_descTextView.text typeA:_typeaField.text typeB:_typebField.text typeC:_typecField.text floor:_floorField.text floorTop:_floorTopField.text area:_areaField.text direction:direction fitment:fitment price:_priceField.text payType:payType address:_addressField.text imgs:imgs canCooking:cooking haveFurniture:furniture tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [XEProgressHUD AlertLoadDone];
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        int status = [jsonRet intValueForKey:@"status"];
        if (status == 200) {
            [XEProgressHUD AlertSuccess:@"发布成功." At:weakSelf.view];
        }else if (status == 201){
            [XEProgressHUD AlertSuccess:@"发布失败." At:weakSelf.view];
        }
        [weakSelf performSelector:@selector(backAction:) withObject:nil afterDelay:0.5];
    }tag:tag];
}

- (void)backAction:(id)sender{
    [super backAction:sender];
}

#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    {
        UIImage* imageAfterScale = image;
        if (image.size.width != image.size.height) {
            CGSize cropSize = image.size;
            cropSize.height = MIN(image.size.width, image.size.height);
            cropSize.width = MIN(image.size.width, image.size.height);
            imageAfterScale = [image imageCroppedToFitSize:cropSize];
        }
        
        NSData* imageData = UIImageJPEGRepresentation(imageAfterScale, R_IMAGE_COMPRESSION_QUALITY);
        
        [self updateImage:image AndData:imageData];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)updateImage:(UIImage *)image AndData:(NSData *)data{
    
    NSMutableArray *dataArray = [NSMutableArray array];
    if (data) {
        QHQFormData* pData = [[QHQFormData alloc] init];
        pData.data = data;
        pData.name = @"file";
        pData.filename = @"file";
        pData.mimeType = @"image/png";
        [dataArray addObject:pData];
    }
    
    [XEProgressHUD AlertLoading:@"图片上传中..." At:self.view];
    __weak PublicHouseViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] updateImageWithData:dataArray tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [XEProgressHUD AlertLoadDone];
        NSString* errorMsg = [REngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"上传失败";
            }
            [XEProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        int status = [jsonRet intValueForKey:@"status"];
        if (status == 200) {
            [XEProgressHUD AlertSuccess:@"上传成功." At:weakSelf.view];
            [weakSelf.imgIds addObject:[jsonRet stringObjectForKey:@"id"]];
            [weakSelf.images addObject:image];
            [weakSelf.imagesGridView reloadData];
        }else{
            [XEProgressHUD AlertError:@"上传失败." At:weakSelf.view];
        }
    }tag:tag];
}

- (IBAction)checkAction:(id)sender {
    UIButton *btn = sender;
    checkType = btn.tag;
  
    UIView *Pickermask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    Pickermask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [[UIApplication sharedApplication].keyWindow addSubview:Pickermask];
    self.Pickermask = Pickermask;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePicker)];
    [Pickermask addGestureRecognizer:tap];
    
    UIPickerView *countPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-230, SCREEN_WIDTH, 200)];
    countPicker.backgroundColor = [UIColor whiteColor];
    countPicker.layer.cornerRadius = 5;
    countPicker.delegate = self;
    countPicker.dataSource = self;
    [Pickermask addSubview:countPicker];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
    confirmBtn.backgroundColor = [UIColor whiteColor];
    confirmBtn.layer.cornerRadius = 5;
    [confirmBtn addTarget:self action:@selector(pickerComfirm) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:SKIN_COLOR forState:UIControlStateNormal];
    [Pickermask addSubview:confirmBtn];
}

- (IBAction)textViewbecomeFirstResponderAction:(id)sender {
    [self doforEndEdit];
}

- (void)doforEndEdit{
    if (self.titleField.isFirstResponder) {
        [self.titleField resignFirstResponder];
    }
    if (self.descTextView.isFirstResponder) {
        [self.descTextView resignFirstResponder];
    }
    if (self.typeaField.isFirstResponder) {
        [self.typeaField resignFirstResponder];
    }
    if (self.typebField.isFirstResponder) {
        [self.typebField resignFirstResponder];
    }
    if (self.typecField.isFirstResponder) {
        [self.typecField resignFirstResponder];
    }
    if (self.floorField.isFirstResponder) {
        [self.floorField resignFirstResponder];
    }
    if (self.floorTopField.isFirstResponder) {
        [self.floorTopField resignFirstResponder];
    }
    if (self.areaField.isFirstResponder) {
        [self.areaField resignFirstResponder];
    }
    if (self.priceField.isFirstResponder) {
        [self.priceField resignFirstResponder];
    }
    if (self.addressField.isFirstResponder) {
        [self.addressField resignFirstResponder];
    }
    if (self.addressField.isFirstResponder) {
        [self.addressField resignFirstResponder];
    }
}

-(void)pickerComfirm
{
    if (checkType == Tag_direction_check) {
        bDirection = YES;
        if ([self.direLabel.text isEqualToString:@"房间朝向"]) {
            self.direLabel.text = [_direTextArray objectAtIndex:0];
            direction = 1;
        }
    }else if(checkType == Tag_Fitment_check){
        bFitment = YES;
        if ([self.fitmentLabel.text isEqualToString:@"房间装修"]) {
            self.fitmentLabel.text = [_fitmentTextArray objectAtIndex:0];
            fitment = 1;
        }
    }else if(checkType == Tag_PayType_check){
        bPayType = YES;
        if ([self.payTypeLabel.text isEqualToString:@"支付形式"]) {
            self.payTypeLabel.text = [_payTextArray objectAtIndex:0];
            payType = 1;
        }
    }
    [self.Pickermask removeFromSuperview];
}

-(void)closePicker
{
    [self.Pickermask removeFromSuperview];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self doforEndEdit];
}

#pragma -UIPickerView代理

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (checkType == Tag_direction_check) {
        return [_direTextArray objectAtIndex:row];
    }else if(checkType == Tag_Fitment_check){
        return [_fitmentTextArray objectAtIndex:row];
    }else {
        return [_payTextArray objectAtIndex:row];
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (checkType == Tag_direction_check) {
        return _direTextArray.count;
    }else if(checkType == Tag_Fitment_check){
        return _fitmentTextArray.count;
    }else {
        return _payTextArray.count;
    }
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    if (checkType == Tag_direction_check) {
        self.direLabel.text = [_direTextArray objectAtIndex:row];
        direction = (int)_direArray[row];
    }else if(checkType == Tag_Fitment_check){
        self.fitmentLabel.text = [_fitmentTextArray objectAtIndex:row];
        fitment = (int)_fitmentArray[row];
    }else if(checkType == Tag_PayType_check){
        self.payTypeLabel.text = [_payTextArray objectAtIndex:row];
        payType = (int)_payArray[row];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
