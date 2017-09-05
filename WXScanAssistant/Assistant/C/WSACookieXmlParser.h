//
//  WSACookieXmlParser.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/5.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAWechatUserModel.h"

typedef void (^completeHanlder)(WSAWechatUserModel* wechatUser);

@interface WSACookieXmlParser : NSObject
- (void)parseCookieXml:(NSString*)xmlString forUUid:(NSString*)uuid completeHanlder:(completeHanlder)completeHanlder;
@end
