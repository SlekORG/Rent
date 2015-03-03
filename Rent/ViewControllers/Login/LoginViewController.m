//
//  LoginViewController.m
//  Rent
//
//  Created by 许 磊 on 15/3/3.
//  Copyright (c) 2015年 slek. All rights reserved.
//

#import "LoginViewController.h"
#import "REngine.h"
#import "XEProgressHUD.h"
#import "RUserInfo.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (nonatomic,strong) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIView *registerAffirmView;
@property (strong, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) IBOutlet UIView *userTypeView;
@property (strong, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *userTypeSwitch;
@property (assign, nonatomic) BOOL isLandlord;

- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.titleNavBar setHidden:YES];
    self.backButton.hidden = !_showBackButton;
    [self.userTypeSwitch addTarget:self action:@selector(toggleSetValue:) forControlEvents:UIControlEventTouchUpInside];
    [self.userTypeSwitch setOn:NO animated:YES];
    _userTypeLabel.text = @"房客";
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

- (void)TextFieldResignFirstResponder{
    [self.verifyCodeTextField resignFirstResponder];
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

-(void)toggleSetValue:(id)sender
{
    UISwitch *toggle = sender;
    BOOL bValue = toggle.on;
    _isLandlord = bValue;
    if (_isLandlord) {
        _userTypeLabel.text = @"房东";
    }else{
        _userTypeLabel.text = @"房客";
    }
}

- (IBAction)loginAction:(id)sender {
    
    _accountTextField.text = [_accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_accountTextField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入手机号"];
        return;
    }
    _passwordTextField.text = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_passwordTextField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入密码"];
        return;
    }
    [self TextFieldResignFirstResponder];
    [XEProgressHUD AlertLoading:@"正在登录..." At:self.view];
    
    __weak LoginViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] loginWithPhone:_accountTextField.text password:_passwordTextField.text tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
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
            [XEProgressHUD AlertSuccess:@"登录成功." At:weakSelf.view];
            NSDictionary *object = jsonRet;
            RUserInfo *userInfo = [[RUserInfo alloc] init];
            [userInfo setUserInfoByJsonDic:object];
            
            [REngine shareInstance].uid = userInfo.uid;
            [REngine shareInstance].account = _accountTextField.text;
            [REngine shareInstance].userPassword = _passwordTextField.text;
            [[REngine shareInstance] saveAccount];
            [REngine shareInstance].userInfo = userInfo;
            [weakSelf performSelector:@selector(loginFinished) withObject:nil afterDelay:1.0];
            
        }else if (status == 201){
            [XEProgressHUD AlertError:@"用户不存在" At:weakSelf.view];
        }else if (status == 202){
            [XEProgressHUD AlertError:@"密码错误" At:weakSelf.view];
        }else if (status == 203){
            [XEProgressHUD AlertError:@"房东账号未审核" At:weakSelf.view];
        }else{
            [XEProgressHUD AlertLoadDone];
        }
    }tag:tag];
    
}

- (IBAction)registerAction:(id)sender {
    
    _accountTextField.text = [_accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_accountTextField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入手机号"];
        return;
    }
    _passwordTextField.text = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_passwordTextField.text.length == 0) {
        [XEProgressHUD lightAlert:@"请输入密码"];
        return;
    }
    [self TextFieldResignFirstResponder];
    [XEProgressHUD AlertLoading:@"正在注册..." At:self.view];
    
    int type = 2;
    if (_isLandlord)
        type = 1;
    else
        type = 2;
    
    __weak LoginViewController *weakSelf = self;
    int tag = [[REngine shareInstance] getConnectTag];
    [[REngine shareInstance] registerWithPhone:_accountTextField.text password:_passwordTextField.text type:[NSString stringWithFormat:@"%d",type] name:_accountTextField.text tag:tag];
    [[REngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
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
            [XEProgressHUD AlertSuccess:@"注册成功." At:weakSelf.view];
//            NSDictionary *object = jsonRet;
//            RUserInfo *userInfo = [[RUserInfo alloc] init];
//            [userInfo setUserInfoByJsonDic:object];
//            
//            [REngine shareInstance].uid = userInfo.uid;
//            [REngine shareInstance].account = _accountTextField.text;
//            [REngine shareInstance].userPassword = _passwordTextField.text;
//            [[REngine shareInstance] saveAccount];
//            [REngine shareInstance].userInfo = userInfo;
//            [weakSelf performSelector:@selector(loginFinished) withObject:nil afterDelay:1.0];
            
        }else if (status == 201){
            [XEProgressHUD AlertError:@"手机号已注册" At:weakSelf.view];
        }else if (status == 202){
            [XEProgressHUD AlertError:@"保存失败" At:weakSelf.view];
        }else{
            [XEProgressHUD AlertLoadDone];
        }
    }tag:tag];
}

-(void)loginFinished{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate signIn];
}

@end
