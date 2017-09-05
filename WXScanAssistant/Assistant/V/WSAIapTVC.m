//
//  WSAIapTVC.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/6.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAIapTVC.h"


@interface WSAIapTVC()
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UILabel* productTitleLabel;
@property (nonatomic, strong) UILabel* productPriceLabel;
@property (nonatomic, strong) UILabel* productDescLabel;
@end


@implementation WSAIapTVC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.productTitleLabel];
    [self.bgView addSubview:self.productPriceLabel];
    [self.bgView addSubview:self.productDescLabel];
    
    weak(self);
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakself.contentView);
        make.top.equalTo(weakself.contentView.mas_top).offset(10);
        make.left.equalTo(weakself.contentView.mas_left).offset(15*kWidth_Scale);
    }];
    [self.productTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.bgView.mas_left).offset(15);
        make.top.equalTo(weakself.bgView.mas_top).offset(10);
        make.right.equalTo(weakself.productPriceLabel.mas_left).offset(-10);
    }];
    [self.productPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakself.bgView.mas_right).offset(-15);
        make.centerY.equalTo(weakself.productTitleLabel.mas_centerY);
    }];
    [self.productDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.bgView.mas_left).offset(15);
        make.centerX.equalTo(weakself.bgView.mas_centerX);
        make.top.equalTo(weakself.productTitleLabel.mas_bottom).offset(5);
        make.bottom.equalTo(weakself.bgView.mas_bottom).offset(-10);
    }];
}

- (UILabel*)productTitleLabel {
    if (!_productTitleLabel) {
        _productTitleLabel = [[UILabel alloc] init];
        _productTitleLabel.textColor = [UIColor darkTextColor];
        _productTitleLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _productTitleLabel;
}

- (UILabel*)productPriceLabel {
    if (!_productPriceLabel) {
        _productPriceLabel = [[UILabel alloc] init];
        _productPriceLabel.textColor = [UIColor darkTextColor];
        _productPriceLabel.textAlignment = NSTextAlignmentRight;
        _productPriceLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _productPriceLabel;
}

- (UILabel*)productDescLabel {
    if (!_productDescLabel) {
        _productDescLabel = [[UILabel alloc] init];
        _productDescLabel.textColor = [UIColor darkTextColor];
        _productDescLabel.numberOfLines = 0;
        _productDescLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _productDescLabel;
}

- (UIView*)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.clipsToBounds = YES;
        _bgView.layer.cornerRadius = 8;
    }
    return _bgView;
}

- (void)setContentWithProduct:(SKProduct *)product {
    if (!product) {
        return;
    }
    self.productTitleLabel.text = product.localizedTitle;
    self.productPriceLabel.text = [self formatPriceStringFromPrice:product.price];
    self.productDescLabel.text = product.localizedDescription;
}

- (NSString*)formatPriceStringFromPrice:(NSDecimalNumber*)price {
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    return [numberFormatter stringFromNumber:price];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.productTitleLabel.text = nil;
    self.productPriceLabel.text = nil;
    self.productDescLabel.text = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    if (selected) {
        self.bgView.layer.borderWidth = 0;
        self.bgView.backgroundColor = [UIColor ColorWithHexString:@"#434343"];
        self.productTitleLabel.textColor = [UIColor whiteColor];
        self.productPriceLabel.textColor = [UIColor whiteColor];
        self.productDescLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.bgView.layer.borderWidth = 1;
        self.bgView.layer.borderColor = [UIColor blackColor].CGColor;
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.productTitleLabel.textColor = [UIColor darkTextColor];
        self.productPriceLabel.textColor = [UIColor darkTextColor];
        self.productDescLabel.textColor = [UIColor darkTextColor];
    }
}

@end
