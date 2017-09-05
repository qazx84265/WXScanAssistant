//
//  WSAIapVC.h
//  WXScanAssistant
//
//  Created by FB on 2017/8/6.
//  Copyright © 2017年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAIapVC : UIViewController
+ (appFeatureVersion)determineVersionByID:(NSString*)productID;
+ (NSString*)determinProductIDByVersion:(appFeatureVersion)version;
+ (NSString*)featureNameFromVersion:(appFeatureVersion)version;
+ (NSUInteger)limitForVersion:(appFeatureVersion)version;
+ (appFeatureVersion)currentAppFeatureVersion;
@end
