//
//  WSASelectButton.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/7.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSASelectButton.h"

@interface WSASelectButton()
@property (nonatomic, strong) UIImageView* selectImageView;
@end

@implementation WSASelectButton

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.selectImageView = [[UIImageView alloc] init];
    self.selectImageView.clipsToBounds = YES;
    self.selectImageView.image = [UIImage imageNamed:@"wsa_check"];
    self.selectImageView.hidden = YES;
    [self addSubview:self.selectImageView];
    
    weak(self);
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.mas_top).offset(0);
        make.right.equalTo(weakself.mas_right).offset(0);
        make.width.height.equalTo(weakself.mas_height).multipliedBy(0.35);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectImageView.hidden = !selected;
}

@end
