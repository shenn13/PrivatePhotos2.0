//
//  XPFTPViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/24.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPFTPViewController.h"
#import "XMFTPServer.h"
@import GoogleMobileAds;

@interface XPFTPViewController ()<GADBannerViewDelegate,GADInterstitialDelegate>{
    GADBannerView *_bannerView;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) XMFTPServer *ftpServer;
//插页广告
@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation XPFTPViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setInterstitial];
    
    CGPoint origin = CGPointMake(0, kScreenHeight - 65 - 64);
    _bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(kScreenWidth, 65)) origin:origin];
    _bannerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bannerView];
    
    _bannerView.adUnitID = AdMob_BannerViewAdUnitID;
    _bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
    
    self.title = NSLocalizedString(@"FTP Service", nil);
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        //显示广告**********************************************
        [self startShowAdMob];
        //*****************************************************
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self stopFTPServer];
}

#pragma mark - Actions

- (IBAction)toggleButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        unsigned int ftpPort = 23023;
        NSString *ip = [XMFTPHelper localIPAddress];
        if (![ip isIP]) {
            sender.selected = !sender.selected;
            [XPProgressHUD showFailureHUD:NSLocalizedString(@"FTP server failed to open, please confirm open WIFI and connect WIFI", nil) toView:self.view];
            return;
        }
        self.textField.text = [NSString stringWithFormat:@"ftp://%@:%d", ip, ftpPort];
        [self stopFTPServer];
        /**
         仅仅开放相片目录
         如果notifyObject传递了self,则需要注意循环引用导致self不能释放的问题,在适当的时候需要自动停止FTP服务器
         */
        _ftpServer = [[XMFTPServer alloc] initWithPort:ftpPort
                                               withDir:photoRootDirectory()
                                          notifyObject:nil];
    } else {
        self.textField.text = nil;
        [self stopFTPServer];
    }
    
    
    //显示广告**********************************************
    [self startShowAdMob];
    //*****************************************************
}

#pragma mark - Private

- (void)stopFTPServer {
    if (_ftpServer) {
        [_ftpServer stopFtpServer];
        _ftpServer = nil;
    }
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
-(void)startShowAdMob{
    
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }else{
        
        NSLog(@"not isReady");
    }
}

#pragma mark - GADInterstitialDelegate -
//GADInterstitial 是仅限一次性使用的对象。若要请求另一个插页式广告，您需要分配一个新的 GADInterstitial 对象。
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    [self setInterstitial];
}
//分配失败重新分配
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [self setInterstitial];
}

@end
