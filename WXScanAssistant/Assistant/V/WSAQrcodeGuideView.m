//
//  WSAQrcodeGuideView.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/7.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAQrcodeGuideView.h"


@interface WSAQrcodeGuideView()
@property (nonatomic, strong) UIImageView* gesImageView;
@property (nonatomic, strong) UILabel* gesLabel;
@property (nonatomic, strong) UIButton* okButton;
@end


@implementation WSAQrcodeGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = RGBA(0, 0, 0, 0.85);
    
    [self addSubview:self.gesImageView];
    [self addSubview:self.gesLabel];
    [self addSubview:self.okButton];
    
    weak(self);
    [self.gesImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself);
        make.width.height.equalTo(@60);
    }];
    [self.gesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.gesImageView.mas_bottom).offset(5);
        make.left.equalTo(weakself.mas_left).offset(50);
        make.centerX.equalTo(weakself.mas_centerX);
    }];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakself.mas_bottom).offset(-60);
        make.centerX.equalTo(weakself.mas_centerX);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
    }];
}

- (UIImageView*)gesImageView {
    if (!_gesImageView) {
        _gesImageView = [[UIImageView alloc] init];
        _gesImageView.clipsToBounds = YES;
        _gesImageView.image = [UIImage imageNamed:@"wsa_guide_ges"];
    }
    return _gesImageView;
}

- (UILabel*)gesLabel {
    if (!_gesLabel) {
        _gesLabel = [[UILabel alloc] init];
        _gesLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:17];
        _gesLabel.text = @"下拉可以关闭";
        _gesLabel.textColor = [UIColor whiteColor];
        _gesLabel.textAlignment = NSTextAlignmentCenter;
    }

    return _gesLabel;
}

- (UIButton*)okButton {
    if (!_okButton) {
        _okButton = [[UIButton alloc] init];
        _okButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:17];
        [_okButton setTitle:@"知道了" forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setBackgroundColor:[UIColor clearColor]];
        _okButton.layer.cornerRadius = kButtonCornerRadius;
        _okButton.layer.masksToBounds = YES;
        _okButton.layer.borderWidth = 1;
        _okButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_okButton addTarget:self action:@selector(okTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (void)okTap:(UIButton*)button {
    
    [USER_DEFAULT setBool:YES forKey:kQRCodeGuideKey];
    
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


+ (UIView*)guideViewInView:(UIView*)view {
    
    for (UIView* v in [view.subviews reverseObjectEnumerator]) {
        if ([v isKindOfClass:[WSAQrcodeGuideView class]]) {
            return v;
        }
    }
    
    return nil;
}

+ (void)show {
    if ([WSAQrcodeGuideView guideViewInView:kKeyWindow]) {
        return;
    }
    
    WSAQrcodeGuideView* guideView = [[WSAQrcodeGuideView alloc] initWithFrame:kKeyWindow.bounds];
    [kKeyWindow addSubview:guideView];
}

+ (void)hide {
    
    UIView* v = [WSAQrcodeGuideView guideViewInView:kKeyWindow];
    if (v) {
        [UIView animateWithDuration:0.35 animations:^{
            v.alpha = 0;
        } completion:^(BOOL finished) {
            [v removeFromSuperview];
        }];
    }
}


@end
