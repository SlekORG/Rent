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

@interface PublicHouseViewController ()<UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GMGridViewDataSource, GMGridViewActionDelegate>{
    CGRect _oldRect;
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
@property (strong, nonatomic) IBOutlet UIButton *cookingButton;

@property (strong, nonatomic) IBOutlet GMGridView *imagesGridView;

@end

@implementation PublicHouseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    _imagesGridView.dataSource = self;
    _imagesGridView.enableEditOnLongPress = YES;
    _imagesGridView.disableEditOnEmptySpaceTap = YES;
    
    if (self.images == nil) {
        self.images = [[NSMutableArray alloc] init];
        self.imgIds = [[NSMutableArray alloc] init];
    }
    [self.imagesGridView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
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

- (void)publicAction{
    if (_titleField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入标题"];
        return;
    }

    
    NSLog(@"===================");
    NSString *imgs = nil;
    if (self.imgIds.count > 0) {
        imgs = [RCommonUtils stringSplitWithCommaForIds:self.imgIds];
    }
    [XEProgressHUD AlertLoading:@"发送中..." At:self.view];
    __weak PublicHouseViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] publicHouseWithUid:[REngine shareInstance].uid title:_titleField.text description:@"weqweq" typeA:@"1" typeB:@"2" typeC:@"3" floor:@"11" floorTop:@"19" area:@"20" direction:@"1" fitment:4 price:@"3000" payType:1 address:@"hahah" imgs:imgs canCooking:1 haveFurniture:1 tag:tag];
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
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }tag:tag];
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
    //    [LSCommonUtils saveImageToAlbum:picker Img:image];
    
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
