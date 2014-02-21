//
//  appUtil.h
//  appTemplate
//
//  Created by Mac on 14/2/20.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface appUtil : NSObject
{
    NSString *token;
    NSString *userName;
    
    NSString *accNamePraram;
    NSString *passwordParam;
    
    NSString *baseURLKey;
    NSString *appCodeKey;
    NSString *loginURIKey;
}

@property (nonatomic, retain)NSString *token;
@property (nonatomic, retain)NSString *userName;
@property (nonatomic, retain)NSString *accNamePraram;
@property (nonatomic, retain)NSString *passwordParam;
@property (nonatomic, retain)NSString *baseURLKey;
@property (nonatomic, retain)NSString *appCodeKey;
@property (nonatomic, retain)NSString *loginURIKey;

+ (id)sharedUtil;
- (void)setRootWindowView:(UIViewController *)VC;
- (NSDictionary *)getSettingsFrom:(NSString *)fileName;
- (NSMutableDictionary *)getPlistFrom:(NSString *)fileName;
- (bool)setPlist:(NSDictionary *)newPlist to:(NSString *)fileName;
- (NSURLRequest *)getHttpConnectionByMethod:(NSString *)method
                                         toURL:(NSString *)URL
                                       useData:(NSString *)data;
@end
