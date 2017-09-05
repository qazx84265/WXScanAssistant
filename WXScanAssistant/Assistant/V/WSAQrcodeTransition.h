//
//  WSAQrcodeTransition.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/4.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WSAQrcodeTransitionType) {
    WSAQrcodeTransitionTypePresent = 0,
    WSAQrcodeTransitionTypeDismiss
};

@interface WSAQrcodeTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) WSAQrcodeTransitionType transitionType;

+ (instancetype)transitionWithTransitionType:(WSAQrcodeTransitionType)type;
- (instancetype)initWithTransitionType:(WSAQrcodeTransitionType)type;

@end
