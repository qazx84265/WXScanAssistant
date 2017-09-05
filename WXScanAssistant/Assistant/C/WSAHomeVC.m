//
//  WSAHomeVC.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/3.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "WSAHomeVC.h"

#import "WSAQRCodeVC.h"
#import "KYExpression.h"

#import "WSAMsgLogVC.h"
#import "WSAIapVC.h"
#import "WSASelectButton.h"


static NSInteger const kMaxTextLength = 300;


@interface WSAHomeVC () <KYExpressionInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate> {
    CGFloat _mLeftMargin;
    CGFloat _mViewWidth;
    CGFloat _mViewHeight;
    CGFloat _mContentWidth;
}
@property (nonatomic, strong) UIButton* purchaseButton; //内购版本/升级

@property (nonatomic, strong) UIScrollView* contentScrollView;

//-- 推广文本
@property (nonatomic, strong) UILabel* textTipLabel;
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UILabel* textViewPlaceholderLabel;
@property (nonatomic, strong) UIButton* emojiButton;
@property (nonatomic, strong) UILabel* textCountLabel;

//-- 推广图片
@property (nonatomic, strong) UILabel* picTipLabel;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIButton* picSelectButton;
@property (nonatomic, strong) UIButton* picDeleteButton;

//-- 推广目标设置
@property (nonatomic, strong) UILabel* targetTipLabel;
@property (nonatomic, strong) WSASelectButton* targetMaleButton;
@property (nonatomic, strong) WSASelectButton* targetFemaleButton;
//@property (nonatomic, strong) WSASelectButton* targetGroupButton;

//-- 推广消息发送间隔
@property (nonatomic, strong) UILabel* msgSendInterval;
@property (nonatomic, strong) UITextField* msgSendTextField;

//-- 商家logo
@property (nonatomic, strong) UILabel* logoTipLabel;
@property (nonatomic, strong) UIImageView* logoImageView;
@property (nonatomic, strong) UIButton* logoSelectButton;
@property (nonatomic, strong) UIButton* logoDeleteButton;


//-- emoji input
@property (nonatomic, strong) KYExpressionInputView* emojiInputView;
@property (nonatomic, strong) NSMutableArray* emojiItems;
@property (nonatomic, strong) NSMutableArray* emojiInput;//已输入的emoji


@property (nonatomic, assign) BOOL isSelectingLogo;
@property (nonatomic, strong) UIImage* picSelected;
@property (nonatomic, strong) UIImage* logoSelected;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@property (nonatomic, strong) WSAQRCodeVC* qrcodeVC;
@end

@implementation WSAHomeVC

#pragma mark -- init
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _mLeftMargin = 20;
    _mViewWidth = self.view.frame.size.width;
    _mViewHeight = self.view.frame.size.height;
    _mContentWidth = _mViewWidth - _mLeftMargin * 2;
    
    self.isSelectingLogo = NO;
    
    [self initEmojiData];
    
    [self initUI];
    
    [self registerNotifications];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self setStatusBarBackgroundColor:[UIColor redColor]];
}

- (void)initUI {
    
//    UIBlurEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView* eview = [[UIVisualEffectView alloc] initWithEffect:effect];
//    eview.frame = self.view.bounds;
//    [self.view addSubview:eview];
    
    self.contentScrollView.frame = CGRectMake(0, 0, _mViewWidth, _mViewHeight-70-kSendStatusButtonHeight);
    self.qrcodeButton.frame = CGRectMake(_mLeftMargin, _mViewHeight-60-kSendStatusButtonHeight, _mContentWidth, 40);
    
    CGFloat top = 40;
    
    self.purchaseButton.frame = CGRectMake(5, top, 150, 30);
    top += 30 + 20;
    
    self.textTipLabel.frame = CGRectMake(_mLeftMargin, top, _mContentWidth, 20);
    
    top += 20 + 5;
    
    self.textView.frame = CGRectMake(_mLeftMargin, top, _mContentWidth, 120);
    
    top += 120 + 5;
    
    self.emojiButton.frame = CGRectMake(_mLeftMargin, top, 25, 25);
    self.textCountLabel.frame = CGRectMake(CGRectGetMaxX(self.textView.frame)-100, top, 100, 25);
    
    [self reframeImageViewWithAnimated:NO];
}

- (void)reframeImageViewWithAnimated:(BOOL)animated {
    
    GCD_MAIN(^{
        if (animated) {
            [UIView animateWithDuration:0.4 animations:^{
                [self reframe];
            }];
        }
        else {
            [self reframe];
        }
    });
}

- (void)reframe {
    
    CGFloat top = CGRectGetMaxY(self.emojiButton.frame) + 15;
    
    self.picTipLabel.frame = CGRectMake(_mLeftMargin, top, _mContentWidth, 20);
    
    top += 20 + 5;
    
    //-- image select
    if (self.picSelected) {
        self.imageView.image = self.picSelected;
        [self.picSelectButton setTitle:@"替换图片" forState:UIControlStateNormal];
        
        self.imageView.frame = CGRectMake(_mLeftMargin, top, 150, 150);
        self.picSelectButton.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame)+20, top+10, _mContentWidth-CGRectGetWidth(self.imageView.frame)-20, 35);
        self.picDeleteButton.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame)+20, CGRectGetMaxY(self.imageView.frame)-10-35, _mContentWidth-CGRectGetWidth(self.imageView.frame)-20, 35);
    }
    else {
        [self.picSelectButton setTitle:@"选择图片" forState:UIControlStateNormal];
        
        self.imageView.frame = CGRectMake(_mLeftMargin, top, 0, 0);
        //CGFloat ww = (_mContentWidth-10)/2;
        self.picSelectButton.frame = CGRectMake(_mLeftMargin, top, _mContentWidth, 35);
        self.picDeleteButton.frame = CGRectMake(CGRectGetMaxX(self.picSelectButton.frame)+10, top, 0, 35);
    }
    
    top = MAX(CGRectGetMaxY(self.imageView.frame), CGRectGetMaxY(self.picDeleteButton.frame)) + 30;
    
    //-- logo select
    self.logoTipLabel.frame = CGRectMake(_mLeftMargin, top, _mContentWidth, 40);
    
    top += CGRectGetHeight(self.logoTipLabel.frame) + 5;
    
    if (self.logoSelected) {
        self.logoImageView.image = self.logoSelected;
        [self.logoSelectButton setTitle:@"替换logo" forState:UIControlStateNormal];
        
        self.logoImageView.frame = CGRectMake(_mLeftMargin, top, 150, 150);
        self.logoSelectButton.frame = CGRectMake(CGRectGetMaxX(self.logoImageView.frame)+20, top+10, _mContentWidth-CGRectGetWidth(self.logoImageView.frame)-20, 35);
        self.logoDeleteButton.frame = CGRectMake(CGRectGetMaxX(self.logoImageView.frame)+20, CGRectGetMaxY(self.logoImageView.frame)-10-35, _mContentWidth-CGRectGetWidth(self.logoImageView.frame)-20, 35);
    }
    else {
        [self.logoSelectButton setTitle:@"选择logo" forState:UIControlStateNormal];
        
        self.logoImageView.frame = CGRectMake(_mLeftMargin, top, 0, 0);
        //CGFloat ww = (_mContentWidth-10)/2;
        self.logoSelectButton.frame = CGRectMake(_mLeftMargin, top, _mContentWidth, 35);
        self.logoDeleteButton.frame = CGRectMake(CGRectGetMaxX(self.logoSelectButton.frame)+10, top, 0, 35);
    }
    
    top = MAX(CGRectGetMaxY(self.logoImageView.frame), CGRectGetMaxY(self.logoDeleteButton.frame)) + 30;
    
    //-- target
    self.targetTipLabel.frame = CGRectMake(_mLeftMargin, top, _mContentWidth, 20);
    
    top += 20 + 5;
    
    CGFloat bs = 15;
    CGFloat bw = (_mContentWidth - 30) / 3;
    CGFloat bh = 35;
    
    self.targetFemaleButton.frame = CGRectMake(_mLeftMargin, top, bw, bh);
    self.targetMaleButton.frame = CGRectMake(CGRectGetMaxX(self.targetFemaleButton.frame)+bs, top, bw, bh);
//    self.targetGroupButton.frame = CGRectMake(CGRectGetMaxX(self.targetMaleButton.frame)+bs, top, bw, bh);
    
    self.contentScrollView.contentSize = CGSizeMake(_mViewWidth, CGRectGetMaxY(self.targetFemaleButton.frame)+30);
}

- (void)initEmojiData {
    NSString *emojiPath = [[NSBundle mainBundle] pathForResource:@"ISEmojiList" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:emojiPath];
    
    for (NSString *text in array) {
        KYExpressionItem *item = [KYExpressionItem itemWithEmoji:text];
        [self.emojiItems addObject:item];
    }
}


#pragma mark -- getters
- (UIButton*)purchaseButton {
    if (!_purchaseButton) {
        _purchaseButton = [[UIButton alloc] init];
        [_purchaseButton setTitle:@"应用内购买" forState:UIControlStateNormal];
        [_purchaseButton setImage:[UIImage imageNamed:@"wsa_iap"] forState:UIControlStateNormal];
        [_purchaseButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_purchaseButton addTarget:self action:@selector(purchase) forControlEvents:UIControlEventTouchUpInside];
        //[_purchaseButton setBackgroundColor:[UIColor ColorWithHexString:@"#007991"]];
        
        [self.contentScrollView addSubview:_purchaseButton];
    }
    return _purchaseButton;
}

- (UIScrollView*)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.backgroundColor = [UIColor ColorWithHexString:@"#FAFAFA"];
        _contentScrollView.delegate = self;
        _contentScrollView.alwaysBounceVertical = YES;
        
        UITapGestureRecognizer * sigleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture)];
        sigleTap.numberOfTapsRequired = 1;
        [_contentScrollView addGestureRecognizer:sigleTap];
        
        [self.view addSubview:_contentScrollView];
    }
    return _contentScrollView;
}

- (UILabel*)textTipLabel {
    if (!_textTipLabel) {
        _textTipLabel = [[UILabel alloc] init];
        _textTipLabel.text = @"推广文本(可插入emoji表情符号)";
        _textTipLabel.textColor = [UIColor blackColor];
        _textTipLabel.font = [UIFont systemFontOfSize:tipFontSize];
        
        [self.contentScrollView addSubview:_textTipLabel];
    }
    return _textTipLabel;
}

- (UITextView*)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.textColor = [UIColor blackColor];
        _textView.backgroundColor = [UIColor ColorWithHexString:@"#F5F5F5"];
        _textView.layer.cornerRadius = kButtonCornerRadius;
        
        [self.contentScrollView addSubview:_textView];
    }
    return _textView;
}

- (UIButton*)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [[UIButton alloc] init];
        [_emojiButton setBackgroundImage:[UIImage imageNamed:@"wsa_emoji"] forState:UIControlStateNormal];
        [_emojiButton addTarget:self action:@selector(keyboardAndEmoji) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentScrollView addSubview:_emojiButton];
    }
    return _emojiButton;
}

- (UILabel*)textCountLabel {
    if (!_textCountLabel) {
        _textCountLabel = [[UILabel alloc] init];
        _textCountLabel.textColor = [UIColor blackColor];
        _textCountLabel.font = [UIFont systemFontOfSize:14.0];
        _textCountLabel.textAlignment = NSTextAlignmentRight;
        _textCountLabel.text = @"12/300";
        
        [self.contentScrollView addSubview:_textCountLabel];
    }
    return _textCountLabel;
}


- (UILabel*)picTipLabel {
    if (!_picTipLabel) {
        _picTipLabel = [[UILabel alloc] init];
        _picTipLabel.text = @"推广图片(最多一张，可选)";
        _picTipLabel.textColor = [UIColor blackColor];
        _picTipLabel.font = [UIFont systemFontOfSize:tipFontSize];
        
        [self.contentScrollView addSubview:_picTipLabel];
    }
    return _picTipLabel;
}

- (UIImageView*)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentScrollView addSubview:_imageView];
    }
    return _imageView;
}

- (UIButton*)picSelectButton {
    if (!_picSelectButton) {
        _picSelectButton = [[UIButton alloc] init];
        _picSelectButton.layer.cornerRadius = kButtonCornerRadius;
        _picSelectButton.layer.masksToBounds = YES;
        _picSelectButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_picSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_picSelectButton setTitle:@"选择图片" forState:UIControlStateNormal];
        [_picSelectButton setBackgroundColor:[UIColor ColorWithHexString:@"#56CCF2"]];
        [_picSelectButton addTarget:self action:@selector(picSelect:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentScrollView addSubview:_picSelectButton];
    }
    return _picSelectButton;
}

- (UIButton*)picDeleteButton {
    if (!_picDeleteButton) {
        _picDeleteButton = [[UIButton alloc] init];
        _picDeleteButton.layer.cornerRadius = kButtonCornerRadius;
        _picDeleteButton.layer.masksToBounds = YES;
        _picDeleteButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_picDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_picDeleteButton setTitle:@"删除图片" forState:UIControlStateNormal];
        [_picDeleteButton setBackgroundColor:[UIColor ColorWithHexString:@"#FF6347"]];
        [_picDeleteButton addTarget:self action:@selector(picDelete:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentScrollView addSubview:_picDeleteButton];
    }
    return _picDeleteButton;
}

- (UILabel*)logoTipLabel {
    if (!_logoTipLabel) {
        _logoTipLabel = [[UILabel alloc] init];
        _logoTipLabel.text = @"商标logo(最多一张，可选，与二维码合成显示)";
        _logoTipLabel.textColor = [UIColor blackColor];
        _logoTipLabel.font = [UIFont systemFontOfSize:tipFontSize];
        _logoTipLabel.numberOfLines = 2;
        
        [self.contentScrollView addSubview:_logoTipLabel];
    }
    return _logoTipLabel;
}

- (UIImageView*)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.clipsToBounds = YES;
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentScrollView addSubview:_logoImageView];
    }
    return _logoImageView;
}

- (UIButton*)logoSelectButton {
    if (!_logoSelectButton) {
        _logoSelectButton = [[UIButton alloc] init];
        _logoSelectButton.layer.cornerRadius = kButtonCornerRadius;
        _logoSelectButton.layer.masksToBounds = YES;
        _logoSelectButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_logoSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_logoSelectButton setTitle:@"选择logo" forState:UIControlStateNormal];
        [_logoSelectButton setBackgroundColor:[UIColor ColorWithHexString:@"#56CCF2"]];
        [_logoSelectButton addTarget:self action:@selector(picSelect:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentScrollView addSubview:_logoSelectButton];
    }
    return _logoSelectButton;
}

- (UIButton*)logoDeleteButton {
    if (!_logoDeleteButton) {
        _logoDeleteButton = [[UIButton alloc] init];
        _logoDeleteButton.layer.cornerRadius = kButtonCornerRadius;
        _logoDeleteButton.layer.masksToBounds = YES;
        _logoDeleteButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_logoDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_logoDeleteButton setTitle:@"删除logo" forState:UIControlStateNormal];
        [_logoDeleteButton setBackgroundColor:[UIColor ColorWithHexString:@"#FF6347"]];
        [_logoDeleteButton addTarget:self action:@selector(picDelete:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentScrollView addSubview:_logoDeleteButton];
    }
    return _logoDeleteButton;
}

- (UILabel*)targetTipLabel {
    if (!_targetTipLabel) {
        _targetTipLabel = [[UILabel alloc] init];
        _targetTipLabel.text = @"推广目标设置(点击选择/取消)";
        _targetTipLabel.textColor = [UIColor blackColor];
        _targetTipLabel.font = [UIFont systemFontOfSize:tipFontSize];
        
        [self.contentScrollView addSubview:_targetTipLabel];
    }
    return _targetTipLabel;
}

- (UIButton*)targetMaleButton {
    if (!_targetMaleButton) {
        _targetMaleButton = [[WSASelectButton alloc] init];
        _targetMaleButton.layer.cornerRadius = kButtonCornerRadius;
        _targetMaleButton.layer.masksToBounds = YES;
        _targetMaleButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_targetMaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_targetMaleButton setTitle:@"男士" forState:UIControlStateNormal];
        [_targetMaleButton addTarget:self action:@selector(male) forControlEvents:UIControlEventTouchUpInside];
        [_targetMaleButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#8e9eab"]] forState:UIControlStateNormal];
        [_targetMaleButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#34e89e"]] forState:UIControlStateSelected];
        
        [_targetMaleButton setSelected:YES];
        [self.contentScrollView addSubview:_targetMaleButton];
    }
    return _targetMaleButton;
}

- (UIButton*)targetFemaleButton {
    if (!_targetFemaleButton) {
        _targetFemaleButton = [[WSASelectButton alloc] init];
        _targetFemaleButton.layer.cornerRadius = kButtonCornerRadius;
        _targetFemaleButton.layer.masksToBounds = YES;
        _targetFemaleButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_targetFemaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_targetFemaleButton setTitle:@"女士" forState:UIControlStateNormal];
        [_targetFemaleButton addTarget:self action:@selector(female) forControlEvents:UIControlEventTouchUpInside];
        [_targetFemaleButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#8e9eab"]] forState:UIControlStateNormal];
        [_targetFemaleButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#34e89e"]] forState:UIControlStateSelected];
        
        [_targetFemaleButton setSelected:YES];
        [self.contentScrollView addSubview:_targetFemaleButton];
    }
    return _targetFemaleButton;
}

//- (UIButton*)targetGroupButton {
//    if (!_targetGroupButton) {
//        _targetGroupButton = [[WSASelectButton alloc] init];
//        _targetGroupButton.layer.cornerRadius = kButtonCornerRadius;
//        _targetGroupButton.layer.masksToBounds = YES;
//        _targetGroupButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
//        [_targetGroupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_targetGroupButton setTitle:@"聊天群组" forState:UIControlStateNormal];
//        [_targetGroupButton addTarget:self action:@selector(groupChat) forControlEvents:UIControlEventTouchUpInside];
//        [_targetGroupButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#8e9eab"]] forState:UIControlStateNormal];
//        [_targetGroupButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#34e89e"]] forState:UIControlStateSelected];
//        
//        [self.contentScrollView addSubview:_targetGroupButton];
//    }
//    return _targetGroupButton;
//}

- (UIButton*)qrcodeButton {
    if (!_qrcodeButton) {
        _qrcodeButton = [[UIButton alloc] init];
        _qrcodeButton.layer.cornerRadius = kButtonCornerRadius;
        _qrcodeButton.layer.masksToBounds = YES;
        _qrcodeButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
        [_qrcodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_qrcodeButton setTitleColor:kButtonDisableTitleColor forState:UIControlStateDisabled];
        [_qrcodeButton setTitle:@"生成二维码" forState:UIControlStateNormal];
        [_qrcodeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [_qrcodeButton setImage:[UIImage imageNamed:@"wsa_qrcode_small"] forState:UIControlStateNormal];
        [_qrcodeButton setBackgroundImage:[UIImage imageWithColor:[UIColor ColorWithHexString:@"#56CCF2"]] forState:UIControlStateNormal];
        [_qrcodeButton setBackgroundImage:[UIImage imageWithColor:kButtonDisableBgColor] forState:UIControlStateDisabled];
        [_qrcodeButton addTarget:self action:@selector(qrcode) forControlEvents:UIControlEventTouchUpInside];
        
        _qrcodeButton.enabled = NO;
        [self.view addSubview:_qrcodeButton];
    }
    return _qrcodeButton;
}


- (KYExpressionInputView*)emojiInputView {
    if (!_emojiInputView) {
        _emojiInputView = [[KYExpressionInputView alloc] init];
        _emojiInputView.toolbarColor = [UIColor whiteColor];
        
        [_emojiInputView addToolbarItemWithImage:[UIImage imageNamed:@"wsa_emoji"] title:nil items:self.emojiItems row:KYUIntegerOrientationMake(4, 4) column:KYUIntegerOrientationMake(7, 13) itemSize:KYSizeOrientationMake(CGSizeMake(45, 45), CGSizeMake(45, 45)) itemSpacing:KYFloatOrientationMake(6, 8) lineSpacing:KYFloatOrientationMake(5.f, 5.f) textPercent:1 backgroundColor:[UIColor clearColor] borderWidth:0];
        
        _emojiInputView.delegate = self;
        
        [_emojiInputView setToolbarSendButtonHidden:NO animated:NO];
        
    }
    return _emojiInputView;
}

- (NSMutableArray*)emojiItems {
    if (!_emojiItems) {
        _emojiItems = [[NSMutableArray alloc] init];
    }
    return _emojiItems;
}

- (NSMutableArray*)emojiInput {
    if (!_emojiInput) {
        _emojiInput = [[NSMutableArray alloc] init];
    }
    return _emojiInput;
}


- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.navigationBar.translucent = NO;
        _imagePickerVc.delegate = self;
    }
    return _imagePickerVc;
}

#pragma mark -- actions
- (void)purchase {
    WSAIapVC* iapVC = [[WSAIapVC alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:iapVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)keyboardAndEmoji {
    if (self.textView.inputView == nil) {
        [self.textView resignFirstResponder];
        self.textView.inputView = self.emojiInputView;
        [self.textView becomeFirstResponder];
    }
    else {
        self.textView.inputView = nil;
        [self.textView becomeFirstResponder];
        [self.textView reloadInputViews];
    }
}

- (void)picSelect:(UIButton*)button {
    [self resignTextView];
    [[WSAMsgSendManager defaultManager] putStatusBack];
    
    self.isSelectingLogo = [button isEqual:self.logoSelectButton];
    
    appFeatureVersion version = [USER_DEFAULT integerForKey:kIAPPurchaseedKey];
    appFeatureVersion requiredVersion = self.isSelectingLogo ? appFeatureVersion_gold : appFeatureVersion_diamond;
    
    if (version < requiredVersion) {
        UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:self.isSelectingLogo?@"无法选择logo":@"无法选择图片" message:[NSString stringWithFormat:@"当前版本: %@\n您需要购买[%@]以上才可以%@", [WSAIapVC featureNameFromVersion:version], [WSAIapVC featureNameFromVersion:requiredVersion], self.isSelectingLogo?@"选择logo":@"推送图片"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[WSAMsgSendManager defaultManager] bringStatusFront];
        }];
        weak(self);
        UIAlertAction* buy = [UIAlertAction actionWithTitle:@"立即购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            GCD_MAIN(^{
                WSAIapVC* iapVC = [[WSAIapVC alloc] init];
                UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:iapVC];
                [weakself presentViewController:nav animated:YES completion:nil];
            });
        }];
        
        [alertVC addAction:cancel];
        [alertVC addAction:buy];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else {
        [self pickImage];
    }
}

- (void)pickImage {
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:self.isSelectingLogo?@"选择logo":@"选择推广图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[WSAMsgSendManager defaultManager] bringStatusFront];
    }];
    weak(self);
    UIAlertAction* album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GCD_MAIN(^{
            [weakself.imagePickerVc.navigationBar setBarTintColor:RGB(247, 247, 247)];
            weakself.imagePickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [weakself presentViewController:weakself.imagePickerVc animated:YES completion:nil];
        });
    }];
    UIAlertAction* takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            
            [weakself.imagePickerVc.navigationBar setBarTintColor:[UIColor blackColor]];
            weakself.imagePickerVc.sourceType = sourceType;
            
            weakself.imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            GCD_MAIN(^{
                [weakself presentViewController:_imagePickerVc animated:YES completion:nil];
            });
        } else {
            NSLog(@"-------- >>>>>>>>>>>>. 摄像头不可用");
            [[WSAMsgSendManager defaultManager] bringStatusFront];
        }
    }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:album];
    [alertVC addAction:takePhoto];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)picDelete:(UIButton*)button {
    [self resignTextView];
    if ([button isEqual:self.picDeleteButton]) {
        self.picSelected = nil;
    }
    else {
        self.logoSelected = nil;
    }
    
    [self reframeImageViewWithAnimated:YES];
}

- (void)male {
    [self.targetMaleButton setSelected:!self.targetMaleButton.isSelected];
    [self updateQRCodeButton];
}

- (void)female {
    [self.targetFemaleButton setSelected:!self.targetFemaleButton.isSelected];
    [self updateQRCodeButton];
}

//- (void)groupChat {
//    [self.targetGroupButton setSelected:!self.targetGroupButton.isSelected];
//    [self updateQRCodeButton];
//}

- (void)qrcode {
    
    [WSAMsgSendManager defaultManager].messageToSend = self.textView.text;
    [WSAMsgSendManager defaultManager].imageToSend = self.imageView.image;
    [WSAMsgSendManager defaultManager].logoToQRCode = self.logoImageView.image;
    [WSAMsgSendManager defaultManager].isSendToMale = self.targetMaleButton.isSelected;
    [WSAMsgSendManager defaultManager].isSendToFemale = self.targetFemaleButton.isSelected;
//    [WSAMsgSendManager defaultManager].isSendToGroup = self.targetGroupButton.isSelected;
    
    WSAQRCodeVC* codeVC = [[WSAQRCodeVC alloc] init];
    codeVC.modalPresentationStyle = UIModalPresentationCustom;
    codeVC.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:codeVC animated:YES completion:nil];
    
}


#pragma mark -- input
- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendStatusShow:) name:WSASendStatusShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendStatusHide:) name:WSASendStatusHideNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textChange:(NSNotification*)noti {
    
    NSString* text = self.textView.text;
    if (text.length > kMaxTextLength) {
        self.textView.text = [text substringToIndex:kMaxTextLength];
    }
    
    [self updateCount];
    [self updateQRCodeButton];
}

- (void)updateCount {
    
    self.textCountLabel.text = [NSString stringWithFormat:@"%zd/%zd", self.textView.text.length, kMaxTextLength];
}

- (void)updateQRCodeButton {
    
    self.qrcodeButton.enabled = (self.textView.text.length > 0 && (self.targetFemaleButton.isSelected || self.targetMaleButton.isSelected/* || self.targetGroupButton.isSelected*/));
    
}

- (void)sendStatusShow:(NSNotification*)noti {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentScrollView.frame = CGRectMake(0, 0, _mViewWidth, _mViewHeight-70-kSendStatusButtonHeight);
        self.qrcodeButton.frame = CGRectMake(_mLeftMargin, _mViewHeight-60-kSendStatusButtonHeight, _mContentWidth, 40);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)sendStatusHide:(NSNotification*)noti {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentScrollView.frame = CGRectMake(0, 0, _mViewWidth, _mViewHeight-70);
        self.qrcodeButton.frame = CGRectMake(_mLeftMargin, _mViewHeight-60, _mContentWidth, 40);
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark -- emoji input
- (void)inputView:(KYExpressionInputView *)inputView didSelectExpression:(id<KYExpressionData>)expression atIndex:(NSUInteger)index container:(KYExpressionViewContainer *)container {
    if ([expression expressionDataType] == kExpressionDataTypeEmoji) {
        NSString* emooji = [expression text];
        [self.emojiInput addObject:emooji];
        NSLog(@"-------->>>>>>>>>>>> %zd", emooji.length);
        
        NSString* oldText = self.textView.text;
        self.textView.text = [oldText stringByAppendingString:emooji];
    }
    else if ([expression expressionDataType] == kExpressionDataTypeDelete) {
        if (self.textView.text.length > 1) {
            //判断是否是表情，表情length为2，所以减去2
            NSString* last2 = [self.textView.text substringWithRange:NSMakeRange(self.textView.text.length - 2, 2)];
            if ([self.emojiInput containsObject:last2]) {
                self.textView.text = [self.textView.text substringToIndex:self.textView.text.length - 2];
                [self.emojiInput removeObject:last2];
            }else{
                self.textView.text = [self.textView.text substringToIndex:self.textView.text.length - 1];
            }
        }else{
            self.textView.text = @"";
        }
    }
    
    [self updateCount];
    [self updateQRCodeButton];
}

- (void)inputView:(KYExpressionInputView *)inputView didClickSendButton:(UIButton *)button  {
//    [self.textView resignFirstResponder];
//    self.textView.inputView = nil;
    
    self.textView.inputView = nil;
    [self.textView becomeFirstResponder];
    [self.textView reloadInputViews];
}


#pragma mark -- image picker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [[WSAMsgSendManager defaultManager] bringStatusFront];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (image) {
            if (self.isSelectingLogo) {
                self.logoSelected = image;
            }
            else {
                self.picSelected = image;
            }
            [self reframeImageViewWithAnimated:YES];
        }
    }
    
    [[WSAMsgSendManager defaultManager] bringStatusFront];
}

#pragma mark -- 
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self resignTextView];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self resignTextView];
}

- (void)handleTapGesture {
    [self resignTextView];
}

- (void)resignTextView {
    [self.textView resignFirstResponder];
    self.textView.inputView = nil;
}

#pragma mark -- dealloc
- (void)dealloc {
    [self removeNotifications];
}

@end
