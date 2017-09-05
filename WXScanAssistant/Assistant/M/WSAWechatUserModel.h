//
//  WSAWechatUserModel.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/4.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAWechatUserModel : NSObject<NSCopying>
@property (nonatomic, copy) NSString* uuid;
@property (nonatomic, copy) NSString* uin;
@property (nonatomic, copy) NSString* skey;
@property (nonatomic, copy) NSString* sid;
@property (nonatomic, copy) NSString* pass_ticket;
@property (nonatomic, copy) NSString* device_id;

@property (nonatomic, copy) NSString* username; //发送消息时使用

@property (nonatomic, copy) NSString* nickname;

@property (nonatomic, copy) NSArray<WSAMessageTargetModel*>* contacts;//联系人

@property (nonatomic, strong) id syncKey;

@property (nonatomic, copy) NSArray* cookies;
@end
