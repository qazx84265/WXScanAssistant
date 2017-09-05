//
//  WSAWechatUserModel.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/4.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSAWechatUserModel.h"

@implementation WSAWechatUserModel
- (instancetype)init {
    if (self = [super init]) {
        self.device_id = [NSString stringWithFormat:@"e%@", [TDTools getRandomPINString:15]];
        self.contacts = [NSArray new];
        self.syncKey = @{};
    }
    return self;
}

- (void)setSyncKey:(id)syncKey {
    _syncKey = syncKey;
    
//    if ([syncKey isKindOfClass:[NSDictionary class]]) {
//        @autoreleasepool {
//            NSDictionary* dic = syncKey;
//            if (dic[@"List"] && [dic[@"List"] isKindOfClass:[NSArray class]]) {
//                NSArray* arr = dic[@"List"];
//                if (arr && arr.count>0) {
//                    NSMutableArray* marr = [NSMutableArray new];
//                    for (NSDictionary* dd in arr) {
//                        NSString* str = [NSString stringWithFormat:@"%@_%@", dd[@"Key"], dd[@"Val"]];
//                        [marr addObject:str];
//                    }
//                    if (marr.count > 0) {
//                        _syncKey = [marr componentsJoinedByString:@"|"];
//                    }
//                }
//            }
//        }
//    }
}

- (id)copyWithZone:(NSZone *)zone {
    WSAWechatUserModel* um = [[[self class] alloc] init];
    um.uuid = self.uuid;
    um.uin = self.uin;
    um.skey = self.skey;
    um.sid = self.sid;
    um.pass_ticket = self.pass_ticket;
    um.device_id = self.device_id;
    um.username = self.username;
    um.nickname = self.nickname;
    um.contacts = [NSArray arrayWithArray:self.contacts];
    um.syncKey = self.syncKey;
    um.cookies = self.cookies;
    
    return um;
}


@end
