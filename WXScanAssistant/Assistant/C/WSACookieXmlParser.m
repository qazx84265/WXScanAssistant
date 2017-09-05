//
//  WSACookieXmlParser.m
//  WXScanAssistant
//
//  Created by FB on 2017/8/5.
//  Copyright © 2017年 FB. All rights reserved.
//

#import "WSACookieXmlParser.h"

@interface WSACookieXmlParser()<NSXMLParserDelegate>

//-- xml parse
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) WSAWechatUserModel *wechatUser;
@property (nonatomic, copy) NSString* uuid;
@property (nonatomic, assign) NSInteger ret;
//标记当前标签，以索引找到XML文件内容
@property (nonatomic, copy) NSString *currentElement;

@property (nonatomic, copy) completeHanlder completeHanlder;


@end


@implementation WSACookieXmlParser

- (instancetype)init {
    if (self = [super init]) {
        self.ret = -1;
    }
    return self;
}

- (void)parseCookieXml:(NSString *)xmlString forUUid:(NSString*)uuid completeHanlder:(completeHanlder)completeHanlder {
    if (!xmlString || [xmlString isEqualToString:@""]) {
        return;
    }
    
    if (completeHanlder) {
        self.completeHanlder = [completeHanlder copy];
    }
    self.uuid = uuid;
    
    self.xmlParser = [[NSXMLParser alloc] initWithData:[NSData dataWithBytes:[xmlString UTF8String] length:xmlString.length]];
    self.xmlParser.delegate = self;
    [self.xmlParser parse];
}

#pragma mark -- xml parse
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    //NSLog(@"-------------->>>>>>>>>>>>>>>>>> parserDidStartDocument...");
}
//准备节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    
    self.currentElement = elementName;
    //NSLog(@"-------------->>>>>>>>>>>>>>>>>> didStartElement %@", self.currentElement);
    
    if ([self.currentElement isEqualToString:@"error"]){
        self.wechatUser = [[WSAWechatUserModel alloc] init];
        self.wechatUser.uuid = self.uuid;
    }
    
}
//获取节点内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //NSLog(@"-------------->>>>>>>>>>>>>>>>>> didStartElement %@", self.currentElement);
    if ([self.currentElement isEqualToString:@"skey"]) {
        self.wechatUser.skey = string;
    }else if ([self.currentElement isEqualToString:@"wxsid"]){
        self.wechatUser.sid = string;
    }else if ([self.currentElement isEqualToString:@"wxuin"]){
        self.wechatUser.uin = string;
    }else if ([self.currentElement isEqualToString:@"pass_ticket"]){
        self.wechatUser.pass_ticket = string;
    }else if ([self.currentElement isEqualToString:@"ret"]){
        self.ret = [string integerValue];
    }
}

//解析完一个节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    //NSLog(@"-------------->>>>>>>>>>>>>>>>>> didEndElement %@", elementName);
    //    if ([elementName isEqualToString:@"student"]) {
    //        [self.list addObject:self.person];
    //    }
    self.currentElement = nil;
}

//解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    //NSLog(@"---------------->>>>>>>>>>>>>>>>>>>>> parserDidEndDocument...");
    if (self.completeHanlder) {
        self.completeHanlder(self.ret==0 ? self.wechatUser : nil);
    }
}



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (self.completeHanlder) {
        self.completeHanlder(nil);
    }
}

@end
