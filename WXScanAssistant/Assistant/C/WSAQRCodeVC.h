//
//  WSAQRCodeVC.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/4.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^closeHandler)();

@interface WSAQRCodeVC : UIViewController

@property (nonatomic, strong) UIImageView* qrcodeImageView;

@property (nonatomic, copy) closeHandler closeHandler;

@property (nonatomic, assign) NSUInteger qrcodeCapInterval; //扫码间隔，默认10s

- (void)reloadQRCode;

@end
