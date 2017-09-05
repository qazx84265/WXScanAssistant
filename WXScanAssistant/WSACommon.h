//
//  WSACommon.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/6.
//  Copyright © 2017年 FB. All rights reserved.
//

#ifndef WSACommon_h
#define WSACommon_h

#define kButtonDisableBgColor RGB(223, 223, 223)
#define kButtonDisableTitleColor RGB(174, 174, 174)

//-- 版本人数限制
static NSUInteger const kDemoMaxUserLimit = 3;
static NSUInteger const kBronzeMaxUserLimit = 20;
static NSUInteger const kSilverMaxUserLimit = 50;
static NSUInteger const kGoldMaxUserLimit = 100;
static NSUInteger const kDiamondMaxUserLimit = 300;
static NSUInteger const kMasterMaxUserLimit = NSUIntegerMax;

static CGFloat const kSendStatusButtonHeight = 50.0;

static CGFloat const kButtonCornerRadius = 5.0f;

static CGFloat const tipFontSize = 16.0f;

static CGFloat const buttonFontSize = 15.0f;

//-- 二维码展示页 guide
static NSString* const kQRCodeGuideKey = @"wsa.qrcode.guide";

//-- 用于保存内购记录，值为内购产品ID
static NSString* const kIAPPurchaseedKey = @"wsa.iap.purchased";

static BOOL IAPEnvironmentProduction = NO; //IAP环境，YES: 生成环境， NO: 测试环境

static NSString* const kIAPProdcutID_demo = @"wechat.assistant.master";
static NSString* const kIAPProdcutID_bronze = @"wechat.assistant.bronze";
static NSString* const kIAPProdcutID_silver = @"wechat.assistant.silver";
static NSString* const kIAPProdcutID_gold = @"wechat.assistant.gold";
static NSString* const kIAPProdcutID_diamond = @"wechat.assistant.diamond";
static NSString* const kIAPProdcutID_master = @"wechat.assistant.master";


//static NSString* const kProductIAPVerifyHost = @"https://buy.itunes.apple.com/verifyReceipt";
//static NSString* const kSandboxIAPVerifyHost = @"https://sandbox.itunes.apple.com/verifyReceipt";

typedef NS_ENUM(NSInteger, appFeatureVersion) {
    appFeatureVersion_demo = 0, //试用版本
    appFeatureVersion_bronze = 101, //青铜版
    appFeatureVersion_silver = 102, //白银版
    appFeatureVersion_gold = 103, //黄金版
    appFeatureVersion_diamond = 104, //钻石版
    appFeatureVersion_master = 105, //大师版
};


#endif /* WSACommon_h */
