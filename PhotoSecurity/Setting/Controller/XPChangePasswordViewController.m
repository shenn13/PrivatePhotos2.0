//
//  XPChangePasswordViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/21.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPChangePasswordViewController.h"
@import GoogleMobileAds;
@interface XPChangePasswordViewController ()<GADBannerViewDelegate,GADInterstitialDelegate>{
    GADBannerView *_bannerView;
}


/// 旧密码输入框
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextFiled;
/// 新密码输入框
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
/// 新密码确认框
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
//插页广告
@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation XPChangePasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Change Password", nil);
    
    [self setInterstitial];
    
    
    CGPoint origin = CGPointMake(0, kScreenHeight - 65 - 64);
    _bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(kScreenWidth, 65)) origin:origin];
    _bannerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bannerView];
    
    _bannerView.adUnitID = AdMob_BannerViewAdUnitID;
    _bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)settingButtonAction:(UIButton *)sender {
    NSString *oldPassword = [self.oldPasswordTextFiled.text trim];
    if (0 == oldPassword.length) {
        [self.oldPasswordTextFiled setText:nil];
        [self.oldPasswordTextFiled shake];
        return;
    }
    if (![XPPasswordTool verifyPassword:oldPassword]) {
        [XPProgressHUD showFailureHUD:NSLocalizedString(@"Old password is incorrect", nil) toView:self.view];
        return;
    }
    NSString *password = [self.passwordTextField.text trim];
    NSString *confirmPassword = [self.confirmPasswordTextField.text trim];
    if (0 == password.length) {
        return [self.passwordTextField shake];
    }
    if (0 == confirmPassword.length) {
        return [self.confirmPasswordTextField shake];
    }
    if (password.length < XPPasswordMinimalLength) {
        [XPProgressHUD showFailureHUD:NSLocalizedString(@"Password length is at least 6 characters", nil) toView:self.view];
        return;
    }
    if (![password isEqualToString:confirmPassword]) {
        [XPProgressHUD showFailureHUD:NSLocalizedString(@"The password entered twice is inconsistent", nil) toView:self.view];
        return;
    }
    [XPPasswordTool storagePassword:password];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [XPProgressHUD showSuccessHUD:NSLocalizedString(@"Password has been modified successfully", nil) toView:window];
    [self.navigationController popViewControllerAnimated:YES];
}


//初始化插页广告
- (void)setInterstitial {
    
    self.interstitial = [self createNewInterstitial];
}

//这个部分是因为多次调用 所以封装成一个方法
- (GADInterstitial *)createNewInterstitial {
    
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:AdMob_CID];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

#pragma mark - GADInterstitialDelegate -
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }else{
        
        NSLog(@"not isReady");
    }
}

//分配失败重新分配
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [self setInterstitial];
}


@end
