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

@interface PublicHouseViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation PublicHouseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"发布房源"];
    [self setRightButtonWithTitle:@"发布" selector:@selector(publicAction)];
}

- (void)publicAction{
    NSLog(@"===================");
    NSString *imgs = nil;
//    if (self.imgIds.count > 0) {
//        imgs = [RCommonUtils stringSplitWithCommaForIds:self.imgIds];
//    }
    [XEProgressHUD AlertLoading:@"发送中..." At:self.view];
    __weak PublicHouseViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] publicHouseWithUid:[REngine shareInstance].uid title:@"qweqwe" description:@"weqweq" typeA:@"1" typeB:@"2" typeC:@"3" floor:@"11" floorTop:@"19" area:@"20" direction:@"1" fitment:15 price:@"2000" payType:1 address:@"hahah" imgs:@"" canCooking:1 haveFurniture:1 tag:tag];
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
//        [XEProgressHUD AlertSuccess:[jsonRet stringObjectForKey:@"result"] At:weakSelf.view];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }tag:tag];
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
        
        [self updateMineBg:imageData];
    }
    [picker dismissModalViewControllerAnimated:YES];
    //    [LSCommonUtils saveImageToAlbum:picker Img:image];
    
}

-(void)updateMineBg:(NSData *)data{
    
    NSMutableArray *dataArray = [NSMutableArray array];
    if (data) {
        QHQFormData* pData = [[QHQFormData alloc] init];
        pData.data = data;
        pData.name = @"bgimg";
        pData.filename = @"bgimg";
        pData.mimeType = @"image/png";
        [dataArray addObject:pData];
    }
    
    [XEProgressHUD AlertLoading:@"封面上传中..." At:self.view];
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
        [XEProgressHUD AlertSuccess:@"上传成功." At:weakSelf.view];
    }tag:tag];
}

@end
