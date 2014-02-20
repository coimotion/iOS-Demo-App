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
}

@property (nonatomic, retain)NSString *token;
@property (nonatomic, retain)NSString *userName;

+ (id)sharedUtil;
- (void)setRootWindowView:(UIViewController *)VC;
- (NSMutableDictionary *)getPlistfrom:(NSString *)fileName;
- (bool)savePlist:(NSDictionary *)newPlist to:(NSString *)fileName;
- (NSURLRequest *)getHttpConnectionByMethod:(NSString *)method
                                         toURL:(NSString *)URL
                                       useData:(NSString *)data;
@end
