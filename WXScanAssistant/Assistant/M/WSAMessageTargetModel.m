//
//  WSAMessageTargetModel.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/7.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAMessageTargetModel.h"

@implementation WSAMessageTargetModel
- (instancetype)init {
    if (self = [super init]) {
        self.targetType = MessageTarget_person;
        self.targetGender = MessageTargetGender_unknown;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    WSAMessageTargetModel* tm = [[[self class] alloc] init];
    tm.targetUsername = self.targetUsername;
    tm.targetType = self.targetType;
    tm.targetGender = self.targetGender;
    
    return tm;
}
@end
