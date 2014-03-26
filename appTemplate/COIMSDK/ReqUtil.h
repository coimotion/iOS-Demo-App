//
//  ReqUtil.h
//  CoimotionSDK
//
//  Created by Mac on 2014/3/24.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface ReqUtil : NSObject

struct attachType {
    __unsafe_unretained NSString * NICON;
    __unsafe_unretained NSString * NFILE;
    __unsafe_unretained NSString * NIMAGE;
    __unsafe_unretained NSString * NVIDEO;
    __unsafe_unretained NSString * NAUDIO;
};

extern const struct attachType nType;

extern const NSString *registerURL;
extern const NSString *activateURL;
extern const NSString *logoutURL;
extern const int maxFileSize;
extern const NSString *reqigsterConnLabel;
//delegate
+ (void)initSDK:(void (^)(NSError *))errBlock;

+ (NSURLConnection *)logoutFrom:(NSString *)relativeURL
                    delegate:(id)aDelegate
               progressTable:(NSMutableDictionary *)dic;

+ (NSURLConnection *)sendTo:(NSString *)relativeURL
              withParameter:(NSDictionary *)params
                   delegate:(id)aDelegate
              progressTable:(NSMutableDictionary *)dic;

+ (NSURLConnection *)loginTo:(NSString *)relativeURL
               withParameter:(NSDictionary *)params
                    delegate:(id)aDelegate
               progressTable:(NSMutableDictionary *)dic;

+ (NSURLConnection *)registerWithParameter:(NSDictionary *)params
                                  delegate:(id)aDelegate
                             progressTable:(NSMutableDictionary *)dic;

+ (NSURLConnection *)attachFiles:(NSArray *)files
                              To:(NSString *)relativeURL
                      withParams:(NSDictionary *)params
                        delegate:(id)aDelegate
                   progressTable:(NSMutableDictionary *)dic;
@end

//delegate protocol
@protocol COIMDelegate <NSObject>
@optional

- (void)coimConnection:(NSURLConnection *)connection
        didReceiveData:(NSData *)data;

- (void)coimConnection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error;

- (void)coimConnection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse *)response;

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection;

- (void)coimHandlingError:(NSError *)error;

- (void)coimConnection:(NSURLConnection *)connection progress:(float)percentage;

@end