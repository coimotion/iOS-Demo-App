//
//  appUtil.m
//  appTemplate
//
//  Created by Mac on 14/2/20.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "appUtil.h"

@implementation appUtil

@synthesize token, userName;

+ (id)sharedUtil
{
    static appUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

- (void)setRootWindowView:(UIViewController *)VC
{
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:VC];
    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
}

- (NSMutableDictionary *)getPlistfrom:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *plistDict;
    if (![fileManager fileExistsAtPath:documentsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    if ([fileManager fileExistsAtPath: filePath])
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }else{
        plistDict = [[NSMutableDictionary alloc] init];
    }
    return plistDict;
}

- (bool)savePlist:(NSDictionary *)newPlist
               to:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:fileName];
    if ([newPlist writeToFile:filePath atomically: YES]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSURLRequest *)getHttpConnectionByMethod:(NSString *)method
                                toURL:(NSString *)URL
                                 useData:(NSString *)data
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if([method isEqualToString:@"GET"]) {
        URL = [URL stringByAppendingFormat:@"?%@", data];
        NSLog(@"URL: %@", URL);
        [request setURL:[[NSURL alloc] initWithString:URL]];
    }
    else {
        [request setURL:[[NSURL alloc] initWithString:URL]];
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:method];
    }
    return request;
}

@end
