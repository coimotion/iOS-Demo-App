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

- (NSURLRequest *)getHttpRequestByMethod:(NSString *)method
                                toURL:(NSString *)URL
                                 useData:(NSString *)data
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if([method isEqualToString:@"GET"]) {
        if (![data isEqual:@""]) {
            URL = [URL stringByAppendingFormat:@"?%@", data];
        }
        [request setURL:[[NSURL alloc] initWithString:URL]];
    }
    else {
        [request setURL:[[NSURL alloc] initWithString:URL]];
        if (![data isEqual:@""]) {
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [request setHTTPMethod:method];
    }
    return request;
}

- (void)logout
{
    NSLog(@"logout, remove token in plist");
    [self saveObject:@"" forKey:coiResParams.token toPlist:coiPlist];
    [self setRootWindowView:[[LoginViewController alloc] init]];
}

- (void)enterApp
{
    TableListingViewController *tableListVC = [[TableListingViewController alloc] init];
    UINavigationController *naviVC1 = [[UINavigationController alloc] initWithRootViewController:tableListVC];
    MapListingViewController *mapListVC = [[MapListingViewController alloc] init];
    UINavigationController *naviVC2 = [[UINavigationController alloc] initWithRootViewController:mapListVC];
    UITabBarController *tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers:[[NSArray alloc] initWithObjects:naviVC1, naviVC2, nil]];
    [self setRootWindowView:tbc];
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
    if ([fileManager fileExistsAtPath: filePath]) {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }
    else {
        plistDict = [[NSMutableDictionary alloc] init];
    }
    
    [plistDict setObject:obj forKey:key];
    
    if ([plistDict writeToFile:filePath atomically: YES]) {
        NSLog(@"Token updated");
    } else {
        NSLog(@"Token update failed");
    }
}

- (id)readObjectForKey:(NSString *)key fromPlist:(NSString *)fileName
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
    if ([fileManager fileExistsAtPath: filePath]) {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }
    else {
        plistDict = [[NSMutableDictionary alloc] init];
    }
    
    return [plistDict objectForKey:key];
}

@end
