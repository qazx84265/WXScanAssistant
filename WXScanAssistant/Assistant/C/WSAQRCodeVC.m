//
//  WSAQRCodeVC.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/4.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAQRCodeVC.h"
#import "WSAQrcodeTransition.h"
#import "WSAWechatUserModel.h"
#import "WSACookieXmlParser.h"
#import "WSAQrcodeGuideView.h"

static CGFloat const kGesOffset = 300.0;
static CGFloat const kDismissOffset = 150.0;
#define kFactor M_PI/(kGesOffset * 2)

@interface WSAQRCodeVC ()<UIViewControllerTransitioningDelegate> {
    BOOL _mIsScanTimeout;
}
@property (nonatomic, strong) UIButton* closeButton;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* tipLabel1; //
@property (nonatomic, strong) UILabel* tipLabel2;
@property (nonatomic, strong) UILabel* tipLabel3;
@property (nonatomic, strong) UIActivityIndicatorView* indicatorView;
@property (nonatomic, strong) UIButton* reloadButton;
@property (nonatomic, strong) UIButton* dutyButton;

@property (nonatomic, assign) CGFloat dampOffset;

@property (nonatomic, strong) NSURLSessionDataTask* qrcodeRequestDataTask;
@property (nonatomic, strong) NSURLSessionDataTask* qrcodeScanDataTask;

@property (nonatomic, strong) NSTimer* qrcodeCapTimer; //扫码间隔定时器
@property (nonatomic, assign) NSInteger timerCount;

@property (nonatomic, strong) UIVisualEffectView* effectView;


@end

@implementation WSAQRCodeVC

- (instancetype)init {
    if (self = [super init]) {
        
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        self.qrcodeCapInterval = 10;
        self.timerCount = self.qrcodeCapInterval;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"------------>>>>>>>>>>>>>>> %@ dealloc", [self class]);
    [self releaseSrc];
}

- (void)releaseSrc {
    
    [self endTimer];
    
    if (self.qrcodeRequestDataTask) {
        [self.qrcodeRequestDataTask cancel];
        self.qrcodeRequestDataTask = nil;
    }
    
    if (self.qrcodeScanDataTask) {
        [self.qrcodeScanDataTask cancel];
        self.qrcodeScanDataTask = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"------------>>>>>>>>>>>>>>> %@ viewWillAppear", [self class]);
    
    [self getCodeFromWechat];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"------------>>>>>>>>>>>>>>> %@ viewWillDisappear", [self class]);
    
    [self releaseSrc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    
    [self initUI];
    
    [self addGesture];
    
    [self showGuideView];
}

- (void)initUI {
    
//    self.view.layer.masksToBounds = NO;
//    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.view.layer.shadowRadius = 4;
//    self.view.layer.shadowOffset = CGSizeMake(0, 4);
//    self.view.layer.shadowOpacity = 0.5;
    
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.tipLabel1];
    [self.view addSubview:self.tipLabel2];
    [self.view addSubview:self.tipLabel3];
    [self.view addSubview:self.dutyButton];
    [self.view addSubview:self.qrcodeImageView];
    [self.view addSubview:self.indicatorView];
    [self.view addSubview:self.reloadButton];
    
    CGFloat www = 290*kHeight_Scale;
    weak(self);
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view.mas_top).offset(10);
        make.left.equalTo(weakself.view).offset(15);
        make.width.height.equalTo(@25);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.view.mas_top).offset(10);
        make.height.equalTo(@25);
    }];
    [self.tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.titleLabel.mas_bottom).offset(30*kHeight_Scale);
        make.left.equalTo(weakself.view.mas_left).offset(30);
        make.height.equalTo(@25);
    }];
    [self.qrcodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.tipLabel1.mas_bottom).offset(5);
        make.width.height.equalTo(@(www));
    }];
    [self.tipLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.qrcodeImageView.mas_bottom).offset(5);
        make.width.equalTo(@(www));
    }];
    [self.reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.tipLabel3.mas_bottom).offset(10);
        make.height.equalTo(@35);
        make.width.equalTo(@(www));
    }];
    [self.tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.reloadButton.mas_bottom).offset(10);
        make.width.equalTo(@(www));
    }];
    [self.dutyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.bottom.equalTo(weakself.view.mas_bottom).offset(-kSendStatusButtonHeight-8);
        make.height.equalTo(@25);
        make.width.equalTo(@(www));
    }];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.qrcodeImageView);
    }];
    [self.indicatorView startAnimating];
}


- (void)addGesture{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self.view addGestureRecognizer:pan];
}

- (void)move:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:self.view];
    
    if(pan.state == UIGestureRecognizerStateBegan){
        self.dampOffset = 0;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        
        if(point.y <= kGesOffset && point.y > 0){
            self.dampOffset = sin(kFactor * point.y ) * kDismissOffset;//简陋的阻尼效果😊
            self.view.transform = CGAffineTransformMakeTranslation(0, self.dampOffset);
        }
    }else if(pan.state == UIGestureRecognizerStateEnded){
        //恢复
        [UIView animateWithDuration: 0.3 delay:0 usingSpringWithDamping:0.93 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.dampOffset = 0;
        }];
    }
    //NSLog(@"%f   %f",point.y,self.dampOffset);
    if(self.dampOffset >= (kDismissOffset - 1 )){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)showGuideView {
    if ([USER_DEFAULT boolForKey:kQRCodeGuideKey]) {
        return;
    }
    
    [WSAQrcodeGuideView show];
}



#pragma mark -- getters
- (UIButton*)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        _closeButton.clipsToBounds = YES;
        //_closeButton.backgroundColor = [UIColor RandomColor];
        [_closeButton setImage:[UIImage imageNamed:@"wsa_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"二维码";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    return _titleLabel;
}

- (UILabel*)tipLabel1 {
    if (!_tipLabel1) {
        _tipLabel1 = [[UILabel alloc] init];
        _tipLabel1.text = @"动态二维码，打印无效";
        _tipLabel1.textAlignment = NSTextAlignmentCenter;
        _tipLabel1.textColor = [UIColor redColor];
        _tipLabel1.font = [UIFont systemFontOfSize:15.0];
    }
    return _tipLabel1;
}

- (UILabel*)tipLabel2 {
    if (!_tipLabel2) {
        _tipLabel2 = [[UILabel alloc] init];
        _tipLabel2.text = @"扫码授权后会向用户微信联系人发送推广消息，推广过程中务必先行告知用户";
        _tipLabel2.textAlignment = NSTextAlignmentCenter;
        _tipLabel2.textColor = [UIColor blackColor];
        _tipLabel2.numberOfLines = 0;
        _tipLabel2.font = [UIFont systemFontOfSize:14.0];
    }
    return _tipLabel2;
}

- (UILabel*)tipLabel3 {
    if (!_tipLabel3) {
        _tipLabel3 = [[UILabel alloc] init];
        _tipLabel3.textAlignment = NSTextAlignmentCenter;
        _tipLabel3.textColor = [UIColor blackColor];
        _tipLabel3.numberOfLines = 0;
        _tipLabel3.font = [UIFont systemFontOfSize:14.0];
    }
    return _tipLabel3;
}

- (UIButton*)dutyButton {
    if (!_dutyButton) {
        _dutyButton = [[UIButton alloc] init];
        [_dutyButton setBackgroundColor:[UIColor whiteColor]];
        [_dutyButton addTarget:self action:@selector(duty) forControlEvents:UIControlEventTouchUpInside];
        _dutyButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        NSMutableAttributedString *astr = [[NSMutableAttributedString alloc] initWithString:@"免责声明"];
        NSRange strRange = {0,[astr length]};
        [astr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [astr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strRange];
        [_dutyButton setAttributedTitle:astr forState:UIControlStateNormal];
    }
    return _dutyButton;
}

- (UIImageView*)qrcodeImageView {
    if (!_qrcodeImageView) {
        _qrcodeImageView = [[UIImageView alloc] init];
        _qrcodeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _qrcodeImageView.clipsToBounds = YES;
        _qrcodeImageView.image = [UIImage imageNamed:@"wsa_qrcode"];
    }
    return _qrcodeImageView;
}

- (UIButton*)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [[UIButton alloc] init];
        _reloadButton.layer.cornerRadius = kButtonCornerRadius;
        _reloadButton.layer.masksToBounds = YES;
        _reloadButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_reloadButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#56CCF2"]] forState:UIControlStateNormal];
        [_reloadButton setBackgroundImage:[UIImage imageWithColor:kButtonDisableBgColor] forState:UIControlStateDisabled];
        [_reloadButton setTitle:@"正在获取二维码..." forState:UIControlStateNormal];
        [_reloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_reloadButton setTitleColor:kButtonDisableTitleColor forState:UIControlStateDisabled];
        [_reloadButton addTarget:self action:@selector(updateCode) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadButton;
}

- (UIActivityIndicatorView*)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}


#pragma mark -- actions

- (void)updateCode {
    _mIsScanTimeout = NO;
    [self getCodeFromWechat];
}

- (void)closeMe {
    if (self.closeHandler) {
        self.closeHandler();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)duty {
    
    UIAlertController* avc = [UIAlertController alertControllerWithTitle:@"免责声明" message:@"本App为单机应用，无网络后台，不收集任何信息\n\n禁止推广谣言|欺诈|低俗|诱导|宗教|或其他违反国家法律内容，由此引发的后果或使用过程中发生的纠纷，由内容发布者自负，本应用不承担任何法律责任。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    [avc addAction:cancel];
    [self presentViewController:avc animated:YES completion:nil];
}

- (void)reloadQRCode {
    _mIsScanTimeout = NO;
    [self getCodeFromWechat];
}


#pragma mark -- network
- (void)getCodeFromWechat {
    if (self.qrcodeRequestDataTask) {
        NSLog(@"-------->>>>>>>>>>>> 已经存在二维码请求，取消之");
        [self.qrcodeRequestDataTask cancel];
        self.qrcodeRequestDataTask = nil;
    }
    
    [self.indicatorView startAnimating];
    weak(self);
    [NetworkHelper getUUidWithCompleteHandler:^(NSString *uuid, NSError *error) {
        if (uuid) {
            weakself.qrcodeRequestDataTask = [NetworkHelper getQRCodeWithUUID:uuid completeHandler:^(UIImage *image, NSError *error) {
                BOOL isSuccess = image&&!error;
                [weakself getQRCodeWithState:isSuccess image:image];
                
                if (isSuccess) {
                    [weakself getCodeScanStateWithUUID:uuid tip:1];
                }
            }];
        }
        else {
            [weakself getQRCodeWithState:NO image:nil];
        }
    }];
}


- (void)getQRCodeWithState:(BOOL)success image:(UIImage*)image {
    self.qrcodeRequestDataTask = nil;
    
    weak(self);
    GCD_MAIN(^{
        strong(self);
        
        [strongself.indicatorView stopAnimating];
        
        if (success && image) {
            strongself.qrcodeImageView.image = image;
            if (strongself.effectView) {
                [strongself.effectView removeFromSuperview];
                strongself.effectView = nil;
            }
            
            [strongself.reloadButton setTitle:@"刷新二维码" forState:UIControlStateNormal];
            strongself.tipLabel3.text = _mIsScanTimeout ? @"扫描超时，请重新扫描" : @"请使用微信扫码并确认";
            
        }
        else {
            strongself.qrcodeImageView.image = [UIImage imageNamed:@"wsa_qrcode"];
            [strongself.reloadButton setTitle:@"获取失败，重新获取" forState:UIControlStateNormal];
            strongself.tipLabel3.text = @"";
        }
    });
}

- (void)getCodeScanStateWithUUID:(NSString*)uuid tip:(NSInteger)tip {
    if (self.qrcodeScanDataTask) {
        NSLog(@"-------->>>>>>>>>>>> 已经存在扫码轮询");
        
        [self.qrcodeScanDataTask cancel];
        self.qrcodeScanDataTask = nil;
    }
    
    weak(self);
    self.qrcodeScanDataTask = [NetworkHelper getQRCodeScanStateWithUUID:uuid tip:tip completeHandler:^(QRCodeScanState state, NSString *loginUrl, NSError *error) {
        strong(self);
        strongself.qrcodeScanDataTask = nil;
        
        if (error) {
            [weakself getCodeFromWechat];
        }
        else {
            GCD_MAIN(^{
                _mIsScanTimeout = NO;
                if (state == QRCodeScanState_wait4Scan) {
                    strongself.tipLabel3.text = @"请使用微信扫描二维码并确认";
                }
                else if (state == QRCodeScanState_wait4Conform) {
                    strongself.tipLabel3.text = @"已扫描，请在手机上确认";
                    [strongself getCodeScanStateWithUUID:uuid tip:0];
                    //[weakself getCodeFromWechat];
                    
                    [strongself startTimer];
                }
                else if (state == QRCodeScanState_conformed) {
                    strongself.tipLabel3.text = @"已确认";
                    //[weakself getCodeFromWechat];
                    //-- 初始化
                    if (loginUrl) {
                        [strongself getInitInfoWithUrlstring:loginUrl];
                    }
                }
                else {
                    _mIsScanTimeout = YES;
                    [weakself restoreQRCodeAndLoadButton];
                    [weakself getCodeFromWechat];
                }
            });
        }
    }];
}

- (void)getInitInfoWithUrlstring:(NSString*)urlString {
    
    weak(self);
    //-- 获取cookie
    [NetworkHelper getWechatCookieUrlstring:urlString completeHandler:^(NSString* cookieXml, NSArray* cookies, NSError *error) {
        strong(self);
        if (cookieXml && !error) {
            WSACookieXmlParser* parser = [[WSACookieXmlParser alloc] init];
            [parser parseCookieXml:cookieXml forUUid:nil completeHanlder:^(WSAWechatUserModel *wechatUser) {
                if (wechatUser) {
                    NSLog(@"----->>>>>>>> uin: %@, sid:%@, skey:%@, pass_ticket:%@", wechatUser.uin, wechatUser.sid, wechatUser.skey, wechatUser.pass_ticket);
                    
                    if (cookies) {
                        wechatUser.cookies = cookies;
                    }
                    
                    [NetworkHelper getWechatInitInfoForUser:wechatUser completeHandler:^(NSString *username, id syncKey, NSError *error) {
                        if (username && !error) {
                            WSAWechatUserModel* user = [wechatUser copy];
                            user.username = username;
                            user.syncKey = syncKey;
                            
                            [[WSAMsgSendManager defaultManager] insertUser:user];
                        }
                        else {
                            NSLog(@"----------->>>>>>>>>>>>>> 微信初始化失败 err: %@", [error localizedDescription]);
                        }
                    }];
                }
            }];
        }
        else {
            NSLog(@"----------->>>>>>>>>>>>>> getWechatCookie err: %@", [error localizedDescription]);
        }
    }];
}


#pragma mark -- timer
- (void)disableQRCodeAndLoadButtonWithTitle:(NSString*)title {
    
    self.reloadButton.enabled = NO;
    
    [self.reloadButton setTitle:title forState:UIControlStateNormal];
    self.reloadButton.titleLabel.text = title;
    
    if (!self.effectView) {
        UIBlurEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        self.effectView.frame = self.qrcodeImageView.bounds;
        [self.qrcodeImageView addSubview:self.effectView];
    }
}

- (void)restoreQRCodeAndLoadButton {
    [self endTimer];
    
    self.timerCount = 0;
    
    self.reloadButton.enabled = YES;
    [self.reloadButton setTitle:@"刷新二维码" forState:UIControlStateNormal];
    
}

- (void)startTimer {
    self.timerCount = self.qrcodeCapInterval;
    [self disableQRCodeAndLoadButtonWithTitle:@"下次扫描(10)"];
    
    if (!self.qrcodeCapTimer) {
        self.qrcodeCapTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    }
}

- (void)endTimer {
    if (self.qrcodeCapTimer) {
        [self.qrcodeCapTimer invalidate];
        self.qrcodeCapTimer = nil;
    }
}

- (void)countdown {
    if (self.timerCount > 0) {
        self.timerCount --;
        
        NSString* str = [NSString stringWithFormat:@"下次扫描(%zd)", self.timerCount];
        [self disableQRCodeAndLoadButtonWithTitle:str];
    }
    else {
        [self restoreQRCodeAndLoadButton];
        _mIsScanTimeout = NO;
        [self getCodeFromWechat];
    }
}



#pragma mark -- transition
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [WSAQrcodeTransition transitionWithTransitionType:WSAQrcodeTransitionTypePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [WSAQrcodeTransition transitionWithTransitionType:WSAQrcodeTransitionTypeDismiss];
}

@end
