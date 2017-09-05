//
//  WSANetworkHelper.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/3.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSANetworkHelper.h"


static NSString* const kAppID = @"wx782c26e4c19acffb";
static NSString* const kLang = @"zh_CN";

@interface WSANetworkHelper(){
    
}
@property (nonatomic, copy) NSString* wechatLoginHost;
@property (nonatomic, strong) AFHTTPSessionManager* afManager;
@end


@implementation WSANetworkHelper

+ (instancetype)helper {
    static dispatch_once_t once;
    static WSANetworkHelper* ins = nil;
    dispatch_once(&once, ^{
        ins = [[WSANetworkHelper alloc] init];
    });
    return ins;
}

- (id)init {
    if (self = [super init]) {
        self.wechatHost = @"wx.qq.com";
        self.wechatLoginHost = @"login.weixin.qq.com";
        
        
        //--afn
        self.afManager = [AFHTTPSessionManager manager];
        
        self.afManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.afManager.requestSerializer.timeoutInterval = 30; //请求超时时间
        [self.afManager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
        
        self.afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.afManager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/plain", @"text/html",@"text/json", @"text/xml",@"text/javascript", @"image/jpeg", nil];

        
        //-- https
        // 先导入证书
        //        NSString *cerPath = [[NSBundle mainBundle] pathForResource:certificate ofType:@"cer"];//证书的路径
        //        NSData *certData = [NSData dataWithContentsOfFile:cerPath];
        //        if (certData) {
        //            // AFSSLPinningModeCertificate 使用证书验证模式
        //            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[NSSet setWithObjects:certData, nil]];
        //
        //            // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
        //            // 如果是需要验证自建证书，需要设置为YES
        //            securityPolicy.allowInvalidCertificates = YES;
        //
        //            //validatesDomainName 是否需要验证域名，默认为YES；
        //            //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
        //            //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
        //            //如置为NO，建议自己添加对应域名的校验逻辑。
        //            //对应域名的校验我认为应该在url中去逻辑判断。
        //            securityPolicy.validatesDomainName = NO;
        //            
        //            self.afManager.securityPolicy = securityPolicy;
        //        }
    }
    return self;
}

- (void)setWechatHost:(NSString *)wechatHost {
    if (!wechatHost || [wechatHost isEqualToString:@""]) {
        return;
    }
    
    _wechatHost = wechatHost;
    _wechatLoginHost = @"login.weixin.qq.com";
    
    if ([_wechatHost containsString:@"wx2.qq.com"]) {
        _wechatLoginHost = @"login.wx2.qq.com";
    }
    else if ([_wechatHost containsString:@"wx8.qq.com"]) {
        _wechatLoginHost = @"login.wx8.qq.com";
    }
    else if ([_wechatHost containsString:@"qq.com"]) {
        _wechatLoginHost = @"login.wx.qq.com";
    }
    else if ([_wechatHost containsString:@"web2.wechat.com"]) {
        _wechatLoginHost = @"login.web2.wechat.com";
    }
    else if ([_wechatHost containsString:@"wechat.com"]) {
        _wechatLoginHost = @"login.web.wechat.com";
    }
}


- (NSURLSessionDataTask*)getUUidWithCompleteHandler:(void (^)(NSString* uuid, NSError *error))completeHandler {
    NSString* url = [NSString stringWithFormat:@"https://%@/jslogin", self.wechatLoginHost];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:kAppID forKey:@"appid"];
    [mdic setObject:@"new" forKey:@"fun"];
    [mdic setObject:@"zh_CN" forKey:@"lang"];
    [mdic setObject:[NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970*1000] forKey:@"_"];
    
    return [self.afManager GET:url parameters:mdic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSString* str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (str) {
                NSString *regexString = @"^.*?\"(.*)\"";
                NSArray* arr = [TDTools matchString:str toRegexString:regexString];
                if (arr.count >= 2) {
                    NSString* uid = [arr objectAtIndex:1];
                    NSLog(@"---------->>>>>>>>>>>>> get uuid %@", uid);
                    completeHandler(uid, nil);
                    return ;
                }
            }
        }
        
        completeHandler(nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---------->>>>>>>>>>>>> get uuid err %@", [error localizedDescription]);
        completeHandler(nil, error);
    }];
}

- (NSURLSessionDataTask*)getQRCodeWithUUID:(NSString*)uuid completeHandler:(void (^)(UIImage *image, NSError *error))completeHandler {
    NSAssert(uuid, @"------->>>>>>>>> uuid must not be nil");
    
    NSString* url = [NSString stringWithFormat:@"https://%@/qrcode/%@", self.wechatLoginHost, uuid];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:@"webwx" forKey:@"t"];
    [mdic setObject:[NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970*1000] forKey:@"_"];
    
    return [self.afManager POST:url parameters:mdic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"---------->>>>>>>>>>>>> get qrcode for uuid: %@", uuid);
        
        if (responseObject) {
            UIImage* image = [UIImage imageWithData:responseObject];
            if (image) {
                completeHandler([self addThumbImage:[WSAMsgSendManager defaultManager].logoToQRCode toQRCodeImage:image], nil);
                return ;
            }
        }
        
        completeHandler(nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---------->>>>>>>>>>>>> get qrcode err %@", [error localizedDescription]);
        completeHandler(nil, error);
    }];
}

- (NSURLSessionDataTask*)getQRCodeScanStateWithUUID:(NSString *)uuid tip:(NSInteger)tip completeHandler:(void (^)(QRCodeScanState, NSString*, NSError *))completeHandler {
    
    NSAssert(uuid, @"------->>>>>>>>> uuid must not be nil");
    
    NSString* url = [NSString stringWithFormat:@"https://%@/cgi-bin/mmwebwx-bin/login", self.wechatLoginHost];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:uuid forKey:@"uuid"];
    [mdic setObject:@"new" forKey:@"fun"];
    [mdic setObject:[NSNumber numberWithInteger:tip] forKey:@"tip"];
    NSTimeInterval ti = [NSDate date].timeIntervalSince1970;
//    NSInteger ii = ~-5;
//    [mdic setObject:[NSNumber numberWithInteger:ii] forKey:@"r"];
    [mdic setObject:[NSString stringWithFormat:@"%.0f", ti*1000] forKey:@"_"];
    
    //NSLog(@"---------->>>>>>>>>>>>>> get scan state url : %@, params: %@", url, mdic);
    
    return [self.afManager GET:url parameters:mdic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            NSString* str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (str) {
                NSLog(@"---------->>>>>>>>>>>>> get scan result %@", str);
                
                NSString *regexString = @"^.*?=(.*)";
                NSArray* arr = [TDTools matchString:str toRegexString:regexString];
                if (arr.count >= 2) {
                    NSString* codeStr = [arr objectAtIndex:1];
                    NSLog(@"---------->>>>>>>>>>>>> get scan code %@", codeStr);
                    NSInteger code = [codeStr integerValue];
                    
                    NSString* loginUrl = nil;
                    if (code == 200) {
                        NSString *regexString1 = @"^[\\s\\S]*?redirect_uri=\"(.*)\"";
                        NSArray* arr1 = [TDTools matchString:str toRegexString:regexString1];
                        if (arr1.count >= 2) {
                            loginUrl = [arr1 objectAtIndex:1];
                            NSString* host = [[[[loginUrl componentsSeparatedByString:@"://"] objectAtIndex:1] componentsSeparatedByString:@"/"] objectAtIndex:0];
                            self.wechatHost = host;
                        }
                        NSLog(@"---------->>>>>>>>>>>>> get scan url %@", loginUrl);
                    }
                    
                    completeHandler(code, loginUrl, nil);
                    return ;
                }
            }
        }
        
        completeHandler(QRCodeScanState_timeout, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---------->>>>>>>>>>>>> get getQRCodeScanState err %@", [error localizedDescription]);
        //completeHandler(QRCodeScanState_timeout, nil, error);
    }];
}

- (NSURLSessionDataTask*)getWechatCookieUrlstring:(NSString *)urlString completeHandler:(void (^)(NSString* cookieXml, NSArray* cookies, NSError *error))completeHandler {
//- (NSURLSessionDataTask*)getWechatInitInfoWithUrlstring:(NSString *)urlString completeHandler:(void (^)(NSString *, NSString *, NSString *, NSString *, NSError *))completeHandler {
    if (!urlString || [urlString isEqualToString:@""]) {
        completeHandler(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:101001 userInfo:@{NSLocalizedDescriptionKey: @"url error"}]);
        return nil;
    }
    
    NSString* url = urlString;
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:@"new" forKey:@"fun"];
    [mdic setObject:@"zh_CN" forKey:@"lang"];
    [mdic setObject:@"v2" forKey:@"version"];
    [mdic setObject:[NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970*1000] forKey:@"_"];
    
    return [self.afManager GET:url parameters:mdic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            NSString* str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if (str) {
                NSLog(@"---------->>>>>>>>>>>>> getWechatCookie %@", str);
                
                NSMutableArray* marr = [NSMutableArray new];
                NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
                for (NSHTTPCookie* cookie in cookies) {
                    if ([cookie.domain containsString:@"qq.com"] || [cookie.domain containsString:@"wechat.com"]) {
                        [marr addObject:cookie];
                    }
                }
                
                completeHandler(str, [NSArray arrayWithArray:marr], nil);
                return ;
            }
        }
        
        completeHandler(nil, nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---------->>>>>>>>>>>>> getWechatCookie err %@", [error localizedDescription]);
        completeHandler(nil, nil, error);
    }];
}

- (NSURLSessionDataTask*)getWechatInitInfoForUser:(WSAWechatUserModel *)user completeHandler:(void (^)(NSString* username, id syncKey, NSError *error))completeHandler {
    if (!user) {
        completeHandler(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:110001 userInfo:@{NSLocalizedDescriptionKey: @"cookie error"}]);
        return nil;
    }
    
    NSString* url = [NSString stringWithFormat:@"https://%@/cgi-bin/mmwebwx-bin/webwxinit?r=%@&lang=zh_CN&pass_ticket=%@&skey=%@", self.wechatHost, [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970], user.pass_ticket, user.skey];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:@{@"Uin": [NSNumber numberWithInteger:[user.uin integerValue]], @"Sid": user.sid, @"Skey": user.skey, @"DeviceID": user.device_id} forKey:@"BaseRequest"];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    NSLog(@"---------->>>>>>>>>>>>>before set cookie getWechatInitInfo url: %@, params: %@, cookies: %@", url, mdic, cookies);
    
    for (NSHTTPCookie* ck in cookies) {
        if ([ck.domain containsString:@"qq.com"] || [ck.domain containsString:@"wechat.com"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:ck];
        }
    }
    if (user.cookies && user.cookies.count > 0) {
        for (NSHTTPCookie* cookie in user.cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
//    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mdic options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"---------->>>>>>>>>>>>>after set cookie getWechatInitInfo url: %@, params: %@, cookies:%@", url, mdic, cookies);

//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //不设置会报-1016或者会有编码问题
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //不设置会报 error 3840
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/JavaScript",@"text/html",@"text/plain", nil]];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask* task = [self.afManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            NSLog(@"---------->>>>>>>>>>>>> getWechatInitInfo: %@", dict);
            if (dict && [dict objectForKey:@"BaseResponse"]) {
                NSDictionary* bDic = [dict objectForKey:@"BaseResponse"];
                id ret = [bDic objectForKey:@"Ret"];
                if (!ret || [ret integerValue] != 0) {
                    completeHandler(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey: @"微信初始化失败"}]);
                    return ;
                }
            }
            
            NSString* username;
            if ([dict objectForKey:@"User"] && [[dict objectForKey:@"User"] objectForKey:@"UserName"]) {
                username = [[dict objectForKey:@"User"] objectForKey:@"UserName"];
            }
            NSString* synckey = [dict objectForKey:@"SyncKey"];
            completeHandler(username, synckey, nil);
        } else {
            NSLog(@"---------->>>>>>>>>>>>> getWechatInitInfo error: %@", error);
            completeHandler(nil, nil, error);
        }
    }];
    [task resume];
    return task;
}


- (NSURLSessionDataTask*)getWechatContactsForUser:(WSAWechatUserModel *)user completeHandler:(void (^)(NSArray<WSAMessageTargetModel*>* contacts, NSError *error))completeHandler {
    if (!user) {
        completeHandler(nil, [NSError errorWithDomain:NSURLErrorDomain code:102101 userInfo:@{NSLocalizedDescriptionKey: @"user info absent"}]);
        return nil;
    }
    
    NSString* url = [NSString stringWithFormat:@"https://%@/cgi-bin/mmwebwx-bin/webwxgetcontact?r=%@&seq=0&lang=zh_CN&skey=%@", self.wechatHost, [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970*1000], user.skey];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:@{@"Uin": user.uin, @"Sid": user.sid, @"Skey": user.skey, @"DeviceID": user.device_id} forKey:@"BaseRequest"];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    NSLog(@"---------->>>>>>>>>>>>>before set cookie getWechatInitInfo url: %@, params: %@, cookies: %@", url, mdic, cookies);
    
    for (NSHTTPCookie* ck in cookies) {
        if ([ck.domain containsString:@"qq.com"] || [ck.domain containsString:@"wechat.com"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:ck];
        }
    }
    if (user.cookies && user.cookies.count > 0) {
        for (NSHTTPCookie* cookie in user.cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    NSLog(@"---------->>>>>>>>>>>>> getWechatContacts url: %@, params: %@, cookies: %@", url, mdic, cookies);
    
    return [self.afManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @autoreleasepool {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            NSLog(@"---------->>>>>>>>>>>>> getcontact: %@", dict);
            
            if (dict && [dict objectForKey:@"MemberList"]) {
                NSMutableArray* marr = [NSMutableArray new];
                NSArray* members = [dict objectForKey:@"MemberList"];
                for (NSDictionary* dd in members) {
                    NSString* username = dd[@"UserName"];
                    if (!username || [username isEqualToString:@""] || [username hasPrefix:@"@@"] || ![username hasPrefix:@"@"]) {
                        continue;
                    }
                    if (!dd[@"SnsFlag"] || [dd[@"SnsFlag"] integerValue] == 0) {
                        continue;
                    }
                    
                    WSAMessageTargetModel* target = [[WSAMessageTargetModel alloc] init];
                    target.targetUsername =username;
                    target.targetNickname = dd[@"NickName"];
                    if ([dd objectForKey:@"Sex"]) {
                        NSInteger sex = [[dd objectForKey:@"Sex"] integerValue];
                        if (![WSAMsgSendManager defaultManager].isSendToMale && sex==1) {
                            continue;
                        }
                        if (![WSAMsgSendManager defaultManager].isSendToFemale && sex==2) {
                            continue;
                        }
                        
                        target.targetGender = sex;
                        [marr addObject:target];
                    }
                    
                }
                completeHandler([NSArray arrayWithArray:marr], nil);
                return ;
            }
            completeHandler(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---------->>>>>>>>>>>>> getcontact error: %@", error);
        completeHandler(nil, error);
    }];
    
//    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:mdic options:NSJSONWritingPrettyPrinted error:nil];
//    [request setHTTPBody:postData];
//    
//    NSURLSessionDataTask* task = [self.afManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        if (!error) {
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
////            NSLog(@"---------->>>>>>>>>>>>> getcontact: %@", dict);
//            if (dict && [dict objectForKey:@"MemberList"]) {
//                NSArray* members = [dict objectForKey:@"MemberList"];
//                for (NSDictionary* dd in members) {
//                    NSLog(@"--------->>>>>>>>>> contact nickname: %@, username: %@, sex: %@", dd[@"NickName"], dd[@"UserName"], dd[@"Sex"]);
//                }
//            }
//        } else {
//            NSLog(@"---------->>>>>>>>>>>>> getcontact error: %@", error);
//        }
//    }];
//    [task resume];
//    return task;
}

- (NSURLSessionDataTask*)getWechatGroupForUser:(WSAWechatUserModel *)user synckey:(id)synckey completeHandler:(void (^)(NSArray<WSAMessageTargetModel *> *, id syncKey, NSError *))completeHandler {
    if (!user) {
        completeHandler(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey: @"user info absent"}]);
        return nil;
    }
    
    long ti = [[NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970*1000] longValue];
    NSString* url = [NSString stringWithFormat:@"https://%@/cgi-bin/mmwebwx-bin/webwxsync?lang=zh_CN&skey=%@&sid=%@&pass_ticket=%@", self.wechatHost, user.skey, user.sid, user.pass_ticket];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:@{@"Uin": [NSNumber numberWithInteger:[user.uin integerValue]], @"Sid": user.sid, @"Skey": user.skey, @"DeviceID": user.device_id} forKey:@"BaseRequest"];
    [mdic setObject:synckey forKey:@"SyncKey"];
    [mdic setObject:[NSNumber numberWithInt:(int)~ti] forKey:@"rr"];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    NSLog(@"---------->>>>>>>>>>>>>before set cookie getWechatInitInfo url: %@, params: %@, cookies: %@", url, mdic, cookies);
    
        for (NSHTTPCookie* ck in cookies) {
            if ([ck.domain containsString:@"qq.com"] || [ck.domain containsString:@"wechat.com"]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:ck];
            }
        }
    if (user.cookies && user.cookies.count > 0) {
        for (NSHTTPCookie* cookie in user.cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    //    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mdic options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"---------->>>>>>>>>>>>>after set cookie getWechatGroupForUser url: %@, params: %@, cookies:%@", url, mdic, cookies);
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask* task = [self.afManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            @autoreleasepool {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSLog(@"---------->>>>>>>>>>>>> getWechatGroupForUser: %@", dict);
                NSMutableArray* marr = [NSMutableArray new];
                if ([dict objectForKey:@"AddMsgList"] && [[dict objectForKey:@"AddMsgList"] isKindOfClass:[NSArray class]]) {
                    NSArray* msglist = [dict objectForKey:@"AddMsgList"];
                    if (msglist && msglist.count > 0) {
                        NSDictionary* msgDic = msglist.firstObject;
                        if ([msgDic objectForKey:@"StatusNotifyUserName"]) {
                            NSString* nname = [msgDic objectForKey:@"StatusNotifyUserName"];
                            NSArray* cts = [nname componentsSeparatedByString:@","];
                            for (NSString* str in cts) {
                                if ([str hasPrefix:@"@@"]) {
                                    WSAMessageTargetModel* target = [[WSAMessageTargetModel alloc] init];
                                    target.targetType = MessageTarget_group;
                                    target.targetUsername = str;
                                    [marr addObject:target];
                                }
                            }
                        }
                    }
                }
                id sk = [dict objectForKey:@"SyncKey"];
                completeHandler([NSArray arrayWithArray:marr], sk, nil);
            }
        } else {
            NSLog(@"---------->>>>>>>>>>>>> getWechatGroupForUser error: %@", error);
            completeHandler(nil, nil, error);
        }
    }];
    [task resume];
    return task;
}


- (NSURLSessionDataTask*)sendMessage:(NSString *)message toUser:(WSAMessageTargetModel*)toUser fromUser:(WSAWechatUserModel*)fromUser completeHandler:(void (^)(WSAMessageTargetModel *toUser, WSAWechatUserModel* fromUser, NSError *error))completeHandler {
    if (!message || !toUser.targetUsername) {
        completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey: @"target username nil"}]);
        return nil;
    }
    
    NSString* lid = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970*100000];
    NSString* url = [NSString stringWithFormat:@"https://%@/cgi-bin/mmwebwx-bin/webwxsendmsg?pass_ticket=%@", self.wechatHost, fromUser.pass_ticket];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:@{@"Uin": [NSNumber numberWithInteger:[fromUser.uin integerValue]], @"Sid": fromUser.sid, @"Skey": fromUser.skey, @"DeviceID": fromUser.device_id} forKey:@"BaseRequest"];
    [mdic setObject:@{@"Type":@"1", @"Content":message, @"FromUserName":fromUser.username,@"ToUserName":toUser.targetUsername, @"LocalID":lid, @"ClientMsgId":lid} forKey:@"Msg"];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    NSLog(@"---------->>>>>>>>>>>>>before set cookie getWechatInitInfo url: %@, params: %@, cookies: %@", url, mdic, cookies);
    
    for (NSHTTPCookie* ck in cookies) {
        if ([ck.domain containsString:@"qq.com"] || [ck.domain containsString:@"wechat.com"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:ck];
        }
    }
    if (fromUser.cookies && fromUser.cookies.count > 0) {
        for (NSHTTPCookie* cookie in fromUser.cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    //    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mdic options:NSJSONWritingPrettyPrinted error:nil];
    //NSLog(@"---------->>>>>>>>>>>>>after set cookie getWechatGroupForUser url: %@, params: %@, cookies:%@", url, mdic, cookies);
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask* task = [self.afManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            @autoreleasepool {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSLog(@"---------->>>>>>>>>>>>> message: %@, response: %@", message, dict);
                if (dict && [dict objectForKey:@"BaseResponse"]) {
                    NSDictionary* bDic = [dict objectForKey:@"BaseResponse"];
                    id ret = [bDic objectForKey:@"Ret"];
                    NSInteger code = ret ? [ret integerValue] : -1;
                    if (code == 0) {
                        completeHandler(toUser, fromUser, nil);
                    }
                    else {
                        completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: code==1101?@"用户已取消授权":@"信息发送失败"}]);
                    }
                }
                else {
                    completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey: @"信息发送失败"}]);
                }
            }
        } else {
            //NSLog(@"---------->>>>>>>>>>>>> message send error: %@", error);
            completeHandler(toUser, fromUser, error);
        }
    }];
    [task resume];
    return task;
}


- (NSURLSessionDataTask*)sendImage:(UIImage *)image toUser:(WSAMessageTargetModel *)toUser fromUser:(WSAWechatUserModel *)fromUser completeHandler:(void (^)(WSAMessageTargetModel *, WSAWechatUserModel *, NSError *))completeHandler {
    if (!image || !toUser.targetUsername) {
        completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey: @"target username nil"}]);
        return nil;
    }
    
    NSString* lid = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970*1000];
    NSString* url = [NSString stringWithFormat:@"https://file2.wx.qq.com/cgi-bin/mmwebwx-bin/webwxuploadmedia?f=json"];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    NSLog(@"---------->>>>>>>>>>>>>before set cookie getWechatInitInfo url: %@, params: %@, cookies: %@", url, mdic, cookies);
    
    for (NSHTTPCookie* ck in cookies) {
        if ([ck.domain containsString:@"qq.com"] || [ck.domain containsString:@"wechat.com"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:ck];
        }
    }
    
    NSString* webwx_data_ticket;
    if (fromUser.cookies && fromUser.cookies.count > 0) {
        for (NSHTTPCookie* cookie in fromUser.cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            if ([cookie.name isEqualToString:@"webwx_data_ticket"]) {
                webwx_data_ticket = cookie.value;
            }
        }
    }
    

    NSString* subfix = @"png";
    NSData *imageData = UIImagePNGRepresentation(image);//UIImageJPEGRepresentation(image,1);
    if (!imageData) {
        NSLog(@"------------>>>>>>>>>>>>>>. image format error");
        return nil;
    }
    NSString *fileName = [lid stringByAppendingPathExtension:subfix];
    NSString* imageSize = [NSString stringWithFormat:@"%zd", imageData.length/*CGImageGetBytesPerRow(image.CGImage) * CGImageGetHeight(image.CGImage)*/];
    
    NSDictionary* dic = @{@"id":[NSString stringWithFormat:@"WU_FILE_%zd", [WSAMsgSendManager defaultManager].media_count],
                          @"name":fileName,
                          @"size":imageSize,
                          @"type":@"image/png",
                          @"mediatype":@"pic",
                          @"webwx_data_ticket":webwx_data_ticket,
                          @"pass_ticket":fromUser.pass_ticket,
                          @"lastModifieDate":[[NSDate date] stringWithFormat:@"yyyy/M/d a h:m:s"],
                          @"uploadmediarequest":[self jsonStringFromDict:@{@"BaseRequest":@{@"Uin": [NSNumber numberWithInteger:[fromUser.uin integerValue]], @"Sid": fromUser.sid, @"Skey": fromUser.skey, @"DeviceID": fromUser.device_id}, @"ClientMediaId":lid, @"TotalLen":@(imageData.length), @"StartPos":@0,@"DataLen":@(imageData.length), @"MediaType":@4, @"UploadType":@2, @"FromUserName":fromUser.username, @"ToUserName":toUser.targetUsername, @"FileMd5":[imageData md5String]}]};
//    return [self.afManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        
//        for (NSString *key in dic) {
//            id value = [dic objectForKey:key];
//            if ([value isKindOfClass:[NSString class]]) {
//                [formData appendPartWithFormData:[value dataUsingEncoding:NSUTF8StringEncoding]];
//            }else if ([value isKindOfClass:[NSData class]]){
//                [formData appendPartWithFormData:value];
//            }
//        }
//        
//        //上传的参数(上传图片，以文件流的格式)
//        [formData appendPartWithFileData:imageData
//                                    name:@"imagefile"
//                                fileName:fileName
//                                mimeType:@"image/png"];
//    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
//        NSLog(@"---------->>>>>>>>>>>>>> sendImage response: %@", dict);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"---------->>>>>>>>>>>>>> sendImage error: %@", error);
//    }];
    
    NSMutableData *postData = [[NSMutableData alloc]init];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    NSString *boundary = @"----WebKitFormBoundaryNQKd04pvAZs2hgCN";
    request.allHTTPHeaderFields = @{@"Accept-Language":@"zh-cn",
                                    @"Content-Type":[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary],
                                    @"User-Agent":@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4",
                                    @"Origin":[NSString stringWithFormat:@"https://%@", self.wechatHost],
                                    @"DNT":@"1",
                                    /*@"Cache-Control":@"no-cache",
                                    @"Pragma":@"no-cache"*/};
    
    for (NSString *key in dic) {
        //循环参数按照部分1、2、3那样循环构建每部分数据
        NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n",boundary,key];
        [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
        
        id value = [dic objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        }else if ([value isKindOfClass:[NSData class]]){
            [postData appendData:value];
        }
        [postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //文件部分
    //NSString *contentType = AFContentTypeForPathExtension(subfix);
    
    NSString *filePair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\nContent-Type: image/%@\r\n\r\n",boundary,fileName,subfix];
    [postData appendData:[filePair dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData]; //加入文件的数据
    
    //设置请求体
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPBody = postData;
    
    //设置请求头总数据长度
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask* task = [self.afManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            @autoreleasepool {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSLog(@"---------->>>>>>>>>>>>>> upload image response: %@", dict);
                NSString* mediaID = nil;
                if ([dict objectForKey:@"MediaId"]) {
                    mediaID = [dict objectForKey:@"MediaId"];
                }
                if (mediaID && ![mediaID isEqualToString:@""]) {
                    //--
                    [self sendImageMessage:mediaID toUser:toUser fromUser:fromUser completeHandler:completeHandler];
                }
                else {
                    completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:1111 userInfo:@{NSLocalizedDescriptionKey: @"图片发送失败"}]);
                }
            }
        } else {
            NSLog(@"---------->>>>>>>>>>>>>> upload image error: %@", error);
            completeHandler(toUser, fromUser, error);
        }
    }];
    [task resume];
    return task;
}


- (NSURLSessionDataTask*)sendImageMessage:(NSString *)mediaID toUser:(WSAMessageTargetModel*)toUser fromUser:(WSAWechatUserModel*)fromUser completeHandler:(void (^)(WSAMessageTargetModel *toUser, WSAWechatUserModel* fromUser, NSError *error))completeHandler {
    if (!mediaID || !toUser.targetUsername) {
        completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey: @"target username nil"}]);
        return nil;
    }
    
    NSString* lid = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970*100000];
    NSString* url = [NSString stringWithFormat:@"https://%@/cgi-bin/mmwebwx-bin/webwxsendmsgimg?fun=async&f=json&lang=zh_CN&pass_ticket=%@", self.wechatHost, fromUser.pass_ticket];
    NSMutableDictionary* mdic = [NSMutableDictionary new];
    [mdic setObject:@{@"Uin": [NSNumber numberWithInteger:[fromUser.uin integerValue]], @"Sid": fromUser.sid, @"Skey": fromUser.skey, @"DeviceID": fromUser.device_id} forKey:@"BaseRequest"];
    [mdic setObject:@{@"Type":@"3", @"MediaId":mediaID, @"FromUserName":fromUser.username,@"ToUserName":toUser.targetUsername, @"LocalID":lid, @"ClientMsgId":lid} forKey:@"Msg"];
    [mdic setObject:@"0" forKey:@"Scene"];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    NSLog(@"---------->>>>>>>>>>>>>before set cookie getWechatInitInfo url: %@, params: %@, cookies: %@", url, mdic, cookies);
    
    for (NSHTTPCookie* ck in cookies) {
        if ([ck.domain containsString:@"qq.com"] || [ck.domain containsString:@"wechat.com"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:ck];
        }
    }
    if (fromUser.cookies && fromUser.cookies.count > 0) {
        for (NSHTTPCookie* cookie in fromUser.cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    //    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mdic options:NSJSONWritingPrettyPrinted error:nil];
    //NSLog(@"---------->>>>>>>>>>>>>after set cookie getWechatGroupForUser url: %@, params: %@, cookies:%@", url, mdic, cookies);
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask* task = [self.afManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            @autoreleasepool {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSLog(@"---------->>>>>>>>>>>>> send image: %@, response: %@", mediaID, dict);
                if (dict && [dict objectForKey:@"BaseResponse"]) {
                    NSDictionary* bDic = [dict objectForKey:@"BaseResponse"];
                    id ret = [bDic objectForKey:@"Ret"];
                    NSInteger code = ret ? [ret integerValue] : -1;
                    if (code == 0) {
                        completeHandler(toUser, fromUser, nil);
                    }
                    else {
                        completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: code==1101?@"用户已取消授权":@"图片发送失败"}]);
                    }
                }
                else {
                    completeHandler(toUser, fromUser, [NSError errorWithDomain:NSURLErrorDomain code:100001 userInfo:@{NSLocalizedDescriptionKey: @"图片发送失败"}]);
                }
            }
        } else {
            //NSLog(@"---------->>>>>>>>>>>>> message send error: %@", error);
            completeHandler(toUser, fromUser, error);
        }
    }];
    [task resume];
    return task;
}


//-- 二维码添加小图片
- (UIImage*)addThumbImage:(UIImage*)thumb toQRCodeImage:(UIImage*)qrImage {
    if (!thumb) {
        return qrImage;
    }
    
    UIGraphicsBeginImageContext(qrImage.size);
    
    //Draw image2
    [qrImage drawInRect:CGRectMake(0, 0, qrImage.size.width, qrImage.size.height)];
    
    //Draw image1
    float r = 50;
    [thumb drawInRect:CGRectMake((qrImage.size.width-r)/2, (qrImage.size.height-r)/2 ,r, r)];
    
    qrImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    return qrImage;
}

-(NSString *)jsonStringFromDict:(NSDictionary *)dict {
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

@end
