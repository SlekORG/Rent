/*
     File: AVCamUtilities.m
 Abstract: A utility class containing a method to find an AVCaptureConnection of a particular media type from an array of AVCaptureConnections.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamUtilities.h"
#import "AVCamCaptureManager.h"
#import <AVFoundation/AVFoundation.h>


//ios7上有定义AVAuthorizationStatus
typedef enum : NSInteger {
    AVAuthorizationStatusNotDetermined_ = 0,
    AVAuthorizationStatusRestricted_,
    AVAuthorizationStatusDenied_,
    AVAuthorizationStatusAuthorized_
} AVAuthorizationStatus_;

@implementation AVCamUtilities

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

//用户是否禁用的相机
//在ios7以前默认相机都是被授权，程序可以直接使用的，只是ios7上并且是新设备上才有打开关闭相机的选项
+(BOOL) userCaptureIsAuthorization
{
    BOOL isAuthor = YES;
    
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus_ status = (NSInteger)[[AVCaptureDevice class] performSelector:@selector(authorizationStatusForMediaType:) withObject: AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied_ == status || AVAuthorizationStatusRestricted_ == status) {
            isAuthor = NO;
        }
//        NSLog(@"status = %ld" , status);
    }
    
    return isAuthor;
}

//用户是否有摄像头
+(BOOL) userCameraIsUsable{
    BOOL isUsable = YES;
//    AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
    if ([AVCamCaptureManager cameraCount] < 1) {
        isUsable = NO;
    }
    return isUsable;
}

@end