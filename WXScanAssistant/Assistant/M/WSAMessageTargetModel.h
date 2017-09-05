//
//  WSAMessageTargetModel.h
//  WXScanAssistant
//  消息接收者
//  Created by FB on 2017/8/7.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MessageTargetType) {
    MessageTarget_person = 0,
    MessageTarget_group,
};

typedef NS_ENUM(NSInteger, MessageTargetGender) {
    MessageTargetGender_unknown = 0,
    MessageTargetGender_male = 1,
    MessageTargetGender_female = 2
};

@interface WSAMessageTargetModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString* targetUsername;
@property (nonatomic, copy) NSString* targetNickname;
@property (nonatomic, assign) MessageTargetGender targetGender;
@property (nonatomic, assign) MessageTargetType targetType;

@property (nonatomic, assign) BOOL sendingResult; //是否发送成功
@property (nonatomic, copy) NSString* sendingErrorDesc;//发送失败描述
@end
