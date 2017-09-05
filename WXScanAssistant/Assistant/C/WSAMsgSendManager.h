//
//  WSAMsgSendManager.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/5.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAMsgSendManager : NSObject

@property (nonatomic, copy) NSString* messageToSend;

@property (nonatomic, strong) UIImage* imageToSend;

@property (nonatomic, strong) UIImage* logoToQRCode;

@property (nonatomic, assign) BOOL isSendToMale;

@property (nonatomic, assign) BOOL isSendToFemale;

@property (nonatomic, assign) BOOL isSendToGroup;

@property (nonatomic, readonly, assign) BOOL isSending; //消息发送中

@property (nonatomic, assign, readonly) NSUInteger media_count;

+ (instancetype)defaultManager;

- (void)insertUser:(WSAWechatUserModel*)user;

- (void)showStatusOnWindow;
- (void)putStatusBack;
- (void)bringStatusFront;
@end


//FOUNDATION_EXPORT NSString* const WSASendStatusShowNotification;
//FOUNDATION_EXPORT NSString* const WSASendStatusHideNotification;
