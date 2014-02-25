//
//  appUtil.h
//  appTemplate
//
//  Created by Mac on 14/2/20.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"

@interface appUtil : NSObject
{}

@property (nonatomic, retain)NSString *token;
@property (nonatomic, retain)NSString *userName;
@property (nonatomic, retain)NSDictionary *shopMenuList;

+ (id)sharedUtil;
- (void)setRootWindowView:(UIViewController *)VC;
- (NSURLRequest *)getHttpRequestByMethod:(NSString *)method
                                         toURL:(NSString *)URL
                                       useData:(NSString *)data;
- (void)logout;
- (void)enterApp;
- (void)saveObject:(id)obj forKey:(NSString *)key toPlist:(NSString *)fileName;
- (id)readObjectForKey:(NSString *)key fromPlist:(NSString *)fileName;
@end
