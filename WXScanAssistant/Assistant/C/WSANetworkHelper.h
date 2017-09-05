//
//  WSANetworkHelper.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/3.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAWechatUserModel.h"

#define NetworkHelper [WSANetworkHelper helper]

typedef NS_ENUM(NSInteger, QRCodeScanState) {
    QRCodeScanState_wait4Scan = 0, //等待扫描
    QRCodeScanState_wait4Conform = 201, //已扫描，等待登录确认
    QRCodeScanState_conformed = 200, //已确认
    QRCodeScanState_timeout = 408 //二维码超时
};


@interface WSANetworkHelper : NSObject

@property (nonatomic, copy) NSString* wechatHost;

+ (instancetype)helper;

//-- 获取uuid
- (NSURLSessionDataTask*)getUUidWithCompleteHandler:(void (^)(NSString* uuid, NSError *error))completeHandler;

//-- 通过uuid获取二维码
- (NSURLSessionDataTask*)getQRCodeWithUUID:(NSString*)uuid completeHandler:(void (^)(UIImage *image, NSError *error))completeHandler;

//-- 二维码扫描、登录状态轮询
- (NSURLSessionDataTask*)getQRCodeScanStateWithUUID:(NSString*)uuid tip:(NSInteger)tip completeHandler:(void (^)(QRCodeScanState state, NSString* loginUrl, NSError *error))completeHandler;

//-- 获取cookie
//- (NSURLSessionDataTask*)getWechatInitInfoWithUrlstring:(NSString*)urlString completeHandler:(void (^)(NSString* sin, NSString* sid, NSString* pass_ticket, NSString* skey, NSError *error))completeHandler;
- (NSURLSessionDataTask*)getWechatCookieUrlstring:(NSString*)urlString completeHandler:(void (^)(NSString* cookieXml, NSArray* cookies, NSError *error))completeHandler;

//-- 初始化微信
- (NSURLSessionDataTask*)getWechatInitInfoForUser:(WSAWechatUserModel*)user completeHandler:(void (^)(NSString* username, id syncKey, NSError *error))completeHandler;

//-- 获取微信好友列表
- (NSURLSessionDataTask*)getWechatContactsForUser:(WSAWechatUserModel*)user completeHandler:(void (^)(NSArray<WSAMessageTargetModel*>* contacts, NSError *error))completeHandler;

//-- 获取群组列表
- (NSURLSessionDataTask*)getWechatGroupForUser:(WSAWechatUserModel*)user synckey:(id)synckey completeHandler:(void (^)(NSArray<WSAMessageTargetModel*>* contacts, id syncKey, NSError *error))completeHandler;

//-- 发送文字信息
- (NSURLSessionDataTask*)sendMessage:(NSString*)message toUser:(WSAMessageTargetModel*)toUser fromUser:(WSAWechatUserModel*)fromUser completeHandler:(void (^)(WSAMessageTargetModel *toUser, WSAWechatUserModel* fromUser, NSError *error))completeHandler;

//-- 发送图片
- (NSURLSessionDataTask*)sendImage:(UIImage*)image toUser:(WSAMessageTargetModel*)toUser fromUser:(WSAWechatUserModel*)fromUser completeHandler:(void (^)(WSAMessageTargetModel *toUser, WSAWechatUserModel* fromUser, NSError *error))completeHandler;
@end
