//
//  appUtil.m
//  appTemplate
//
//  Created by Mac on 14/2/20.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "appUtil.h"

@implementation appUtil

@synthesize token, userName, shopMenuList;

+ (id)sharedUtil
{
    static appUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

- (id)init {
    self = [super init];
    if (self) {
        shopMenuList = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"menu1", @"menu2", @"menu3", nil] forKeys:[[NSArray alloc] initWithObjects:@"50嵐", @"南傳鮮奶", @"鮮茶道", nil]];
    }
    return self;
}

- (void)setRootWindowView:(UIViewController *)VC
{
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:VC];
    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
}

- (NSURLRequest *)getHttpConnectionByMethod:(NSString *)method
                                toURL:(NSString *)URL
                                 useData:(NSString *)data
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if([method isEqualToString:@"GET"]) {
        URL = [URL stringByAppendingFormat:@"?%@", data];
        [request setURL:[[NSURL alloc] initWithString:URL]];
    }
    else {
        [request setURL:[[NSURL alloc] initWithString:URL]];
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:method];
    }
    return request;
}

- (void)logout
{
    [self setRootWindowView:[[LoginViewController alloc] init]];
}

- (void)saveObject:(id)obj forKey:(NSString *)key toPlist:(NSString *)fileName
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
    [plistDict setObject:obj forKey:key];
    if ([plistDict writeToFile:filePath atomically: YES]) {
        NSLog(@"Token updated");
    } else {
        NSLog(@"Token update failed");
    }
}

@end
