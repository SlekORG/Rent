//
//  LoginViewController.m
//  Rent
//
//  Created by 许 磊 on 15/3/3.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (nonatomic,strong) IBOutlet UIButton *backButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.titleNavBar setHidden:YES];
    self.backButton.hidden = !_showBackButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender{
    if (_backActionCallBack) {
        _backActionCallBack(YES);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
