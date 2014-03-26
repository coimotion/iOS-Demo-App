//
//  ReqUtil.m
//  CoimotionSDK
//
//  Created by Mac on 2014/3/24.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "ReqUtil.h"

@implementation ReqUtil {}

#define ErrorDomain @"com.coimotion.csdk"
// private
typedef enum {
    ERR_NOT_INIT = -100,
    ERR_LACK_APP_INFO,
    ERR_PARAM,
    ERR_NO_FILE,
    ERR_SIZE_OVER
}ErrorFailed;

// public struct
const struct attachType nType = {
    .NICON = @"1",
    .NFILE = @"2",
    .NIMAGE = @"3",
    .NVIDEO = @"4",
    .NAUDIO = @"5"
};

//private variables/consts
const NSString *registerURL = @"core/user/register";
const NSString *activateURL = @"core/user/activate";
const NSString *logoutURL = @"core/user/logout";
const NSString *reqigsterConnLabel = @"coimRegisterConn";
const int maxFileSize = 1000 * 1000;

static NSString *plistFilePath = @"";
static NSString *baseURL;
static NSString *appKey;
static NSString *appCode;
static NSMutableDictionary *connectionProgress;
id delegate;

// COIMDelegates
+ (NSURLConnection *)logoutFrom:(NSString *)relativeURL
                       delegate:(id)aDelegate
                  progressTable:(NSMutableDictionary *)dic
{
    if(![delegate isEqual:aDelegate]) {
        delegate = aDelegate;
        connectionProgress = dic;
    }
    if([plistFilePath isEqual: @""]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"ReqUtil is not initialized"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_NOT_INIT userInfo:userInfo];
        if(//[delegate conformsToProtocol:@protocol(COIMDelegateMethods)] &&
           [delegate respondsToSelector:@selector(coimHandlingError:)]) {
            [delegate coimHandlingError:error];
        }
        else
            NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    
    NSMutableDictionary *newParams = [NSMutableDictionary new];
    [newParams setObject:appKey forKey:@"_key"];
    [newParams setObject:[self getToken] forKey:@"token"];
    [self clearToken];
    /*
     waiting for https
     */
    NSString *urlStr = [[NSString alloc] initWithFormat:@"http://%@.coimapi.net/%@", appCode, relativeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlStr]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:newParams options:NSJSONWritingPrettyPrinted error:nil]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return conn;
}

+ (NSURLConnection *)attachFiles:(NSArray *)files
                              To:(NSString *)relativeURL
                      withParams:(NSDictionary *)params
                        delegate:(id)aDelegate
                   progressTable:(NSMutableDictionary *)dic
{
    if(![delegate isEqual:aDelegate]) {
        delegate = aDelegate;
        connectionProgress = dic;
    }
    if([plistFilePath isEqual: @""]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"ReqUtil is not initialized"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_NOT_INIT userInfo:userInfo];
        if(//[delegate conformsToProtocol:@protocol(COIMDelegateMethods)] &&
           [delegate respondsToSelector:@selector(coimHandlingError:)]) {
            [delegate coimHandlingError:error];
        }
        else
            NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    
    for(int i = 0; i < [files count]; i++) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath: [files objectAtIndex:i]]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"file(s) is not existed"                                                                      forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_NO_FILE userInfo:userInfo];
            if([delegate respondsToSelector:@selector(coimHandlingError:)]) {
                [delegate coimHandlingError:error];
            }
            else
                NSLog(@"error: %@", [error localizedDescription]);
            return nil;
        }
    }
    int totalSize = 0;
    for(int i = 0; i < [files count]; i++) {
        NSError *err = nil;
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[files objectAtIndex:i] error:nil];
        if(err != nil) {
            NSLog(@"error: %@", [err localizedDescription]);
            
            if([delegate respondsToSelector:@selector(coimHandlingError:)]) {
                [delegate coimHandlingError:err];
            }
            return nil;
        }
        //[[NSFileManager defaultManager] fileAttributesAtPath:[files objectAtIndex:i] traverseLink:YES];
        totalSize += [fileDictionary fileSize];
        
        if(totalSize > maxFileSize) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"size of all files is over 1 M"                                                                      forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_SIZE_OVER userInfo:userInfo];
            
            NSLog(@"error: %@", [error localizedDescription]);
            if(//[delegate conformsToProtocol:@protocol(COIMDelegateMethods)] &&
               [delegate respondsToSelector:@selector(coimHandlingError:)]) {
                [delegate coimHandlingError:error];
            }
            return nil;
        }
    }
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://%@.coimapi.net/%@", appCode, relativeURL];
    NSString *boundary = [[NSString alloc] initWithFormat:@"------%f%d", [[NSDate date] timeIntervalSince1970], arc4random() % 1000];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSMutableData *body = [NSMutableData data];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSLog(@"set token");
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [self getToken]] dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"set nType");
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"nType\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:@"nType"]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    for(int i=0; i< [files count]; i++) {
        NSString *filename = @"";
        NSURL* fileUrl = [NSURL fileURLWithPath:[files objectAtIndex:i]];
        NSURLRequest* fileUrlRequest = [[NSURLRequest alloc] initWithURL:fileUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:.1];
        
        NSError* error = nil;
        NSURLResponse* response = nil;
        NSData* fileData = [NSURLConnection sendSynchronousRequest:fileUrlRequest returningResponse:&response error:&error];
        NSString* mimeType = [response MIMEType];
        NSArray *parts = [fileUrl pathComponents];
        filename = [parts objectAtIndex:[parts count]-1];
        
        if (fileData != nil) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"att%d\"; filename=\"%@\"\r\n", i, filename] dataUsingEncoding:NSUTF8StringEncoding]];
            NSString *contentType = [[NSString alloc] initWithFormat:@"Content-Type: %@\r\n\r\n", mimeType];
            [body appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:fileData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //delegate = [coimViewController new];
    return conn;
}

+ (NSURLConnection *)registerWithParameter:(NSDictionary *)params delegate:(id)aDelegate progressTable:(NSMutableDictionary *)dic
{
    
    if(![delegate isEqual:aDelegate]) {
        delegate = aDelegate;
        connectionProgress = dic;
    }
    
    if([plistFilePath isEqual: @""]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"ReqUtil is not initialized"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_NOT_INIT userInfo:userInfo];
        if(//[delegate conformsToProtocol:@protocol(COIMDelegateMethods)] &&
           [delegate respondsToSelector:@selector(coimHandlingError:)]) {
            [delegate coimHandlingError:error];
        }
        else
            NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    
    if([params objectForKey:@"passwd"] == nil || [params objectForKey:@"passwd2"] == nil || [params objectForKey:@"accName"] == nil) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Wrong Parameters"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_PARAM userInfo:userInfo];
        if([delegate respondsToSelector:@selector(coimHandlingError:)]) {
            [delegate coimHandlingError:error];
        }
        else
            NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    //[newParams setObject:[self sha1:[params objectForKey:@"passwd"]] forKey:@"passwd"];
    //[newParams setObject:[self sha1:[params objectForKey:@"passwd2"]] forKey:@"passwd2"];
    [newParams setObject:appKey forKey:@"_key"];
    /*
        waiting for https
     */
    NSString *urlStr = [[NSString alloc] initWithFormat:@"http://%@.coimapi.net/%@", appCode, registerURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlStr]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:newParams options:NSJSONWritingPrettyPrinted error:nil]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn setAccessibilityLabel:[NSString stringWithFormat:@"%@", reqigsterConnLabel]];
    return conn;
}

+ (NSURLConnection *)loginTo:(NSString *)relativeURL withParameter:(NSDictionary *)params delegate:(id)aDelegate progressTable:(NSMutableDictionary *)dic
{
    if(![delegate isEqual:aDelegate]) {
        delegate = aDelegate;
        connectionProgress = dic;
    }
    
    if([plistFilePath isEqual: @""]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"ReqUtil is not initialized"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_NOT_INIT userInfo:userInfo];
        if([delegate respondsToSelector:@selector(coimHandlingError:)]) {
            [delegate coimHandlingError:error];
        }
        else
            NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    
    if([params objectForKey:@"passwd"] == nil || [params objectForKey:@"accName"] == nil) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Wrong Parameters"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_PARAM userInfo:userInfo];
        if([delegate respondsToSelector:@selector(coimHandlingError:)]) {
            [delegate coimHandlingError:error];
        }
        else
            NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    [newParams setObject:appKey forKey:@"_key"];
    /*
        waiting for https
     */
    NSString *urlStr = [[NSString alloc] initWithFormat:@"http://%@.coimapi.net/%@", appCode, relativeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlStr]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:newParams options:NSJSONWritingPrettyPrinted error:nil]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return conn;
}

+ (NSURLConnection *)sendTo:(NSString *)relativeURL withParameter:(NSDictionary *)params delegate:(id)aDelegate progressTable:(NSMutableDictionary *)dic
{
    if(![delegate isEqual:aDelegate]) {
        delegate = aDelegate;
        connectionProgress = dic;
    }
    
    if([plistFilePath isEqual: @""]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"ReqUtil is not initialized"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_NOT_INIT userInfo:userInfo];
        if([delegate respondsToSelector:@selector(coimHandlingError:)]) {
            [delegate coimHandlingError:error];
        }
        else
            NSLog(@"error: %@", [error localizedDescription]);
        return nil;
    }
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    NSLog(@"token: %@", [self getToken]);
    [newParams setObject:appKey forKey:@"_key"];
    [newParams setObject:[self getToken] forKey:@"token"];
    
    NSString *urlStr = [[NSString alloc] initWithFormat:@"http://%@.coimapi.net/%@", appCode, relativeURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlStr]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:newParams options:NSJSONWritingPrettyPrinted error:nil]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return conn;
}
// NSURLConnectionDelegates

+ (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"didSendBodyData");
    if(connectionProgress != nil){
        NSArray *progress = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", totalBytesWritten], [NSString stringWithFormat:@"%d", totalBytesExpectedToWrite], nil];
        [connectionProgress setValue:progress forKey:[NSString stringWithFormat:@"%d", [connection hash]]];
    
        if([delegate respondsToSelector:@selector(coimConnection:progress:)]) {
            NSArray *p = [connectionProgress objectForKey:[NSString stringWithFormat:@"%d",[connection hash]]];
            float prog = [[p objectAtIndex:0] floatValue] / [[p objectAtIndex:1] floatValue]  * 100.0f;
            [delegate coimConnection:connection progress:prog];
        }
    }
}

+ (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    NSLog(@"data size: %d", [data length]);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([dic objectForKey:@"token"] != nil) {
        [self setToken:[dic objectForKey:@"token"]];
        
        NSLog(@"token updated");
    }
    
    if ([[connection accessibilityLabel] isEqualToString:[NSString stringWithFormat:@"%@", reqigsterConnLabel]]) {
        NSLog(@"register");
        if ([[dic objectForKey:@"errCode"] integerValue] == 0) {
            NSString *actID = [[dic objectForKey:@"value"] objectForKey:@"actID"];
            NSString *urlStr = [[NSString alloc] initWithFormat:@"http://%@.coimapi.net/%@/%@", appCode, activateURL, actID];
            NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:appKey, @"_key", nil];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlStr]];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil]];
            [request setHTTPMethod:@"POST"];
            connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [connection setAccessibilityLabel:@""];
        }
    }
    else {
        if([delegate respondsToSelector:@selector(coimConnection:didReceiveData:)]) {
            [delegate coimConnection:connection didReceiveData:data];
        }
    }
}

+ (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"(SDK)didFailWithError");
    if([delegate respondsToSelector:@selector(coimConnection:didFailWithError:)]) {
        [delegate coimConnection:connection didFailWithError:error];
    }
}

+ (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"(SDK)didReceiveResponse");
    //NSLog(@"target size: %lld", [response expectedContentLength]);
    //if ([response expectedContentLength] == -1) {
    //    [connectionProgress removeObjectForKey:[NSString stringWithFormat:@"%d", [connection hash]]];
    //}
    if([delegate respondsToSelector:@selector(coimConnection:didReceiveResponse:)]) {
        [delegate coimConnection:connection didReceiveResponse:response];
    }
}

+ (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    NSLog(@"(SDK)didWriteData: %lld / %lld", bytesWritten, totalBytesWritten);
    if(connectionProgress != nil) {
        NSString *writeBytes = [NSString stringWithFormat:@"%lld", bytesWritten];
        NSString *totalBytes = [NSString stringWithFormat:@"%lld", totalBytesWritten];
        NSArray *a = [[NSArray alloc] initWithObjects:writeBytes, totalBytes, nil];
        [connectionProgress setObject:a forKey:[NSString stringWithFormat:@"%d", [connection hash]]];
        if([delegate respondsToSelector:@selector(coimConnection:progress:)]) {
            NSArray *p = [connectionProgress objectForKey:[NSString stringWithFormat:@"%d",[connection hash]]];
            float prog = [[p objectAtIndex:0] floatValue] / [[p objectAtIndex:1] floatValue]  * 100.0f;
            [delegate coimConnection:connection progress:prog];
        }
    }
    
}

+ (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"(SDK)connectionDidFinishLoading");
    if([connectionProgress count] != 0 &&
       [connectionProgress objectForKey:[NSString stringWithFormat:@"%d", [connection hash]]] != nil) {
        NSLog(@"remove this connection from progress table");
        [connectionProgress removeObjectForKey:[NSString stringWithFormat:@"%d", [connection hash]]];
    }
    if([delegate respondsToSelector:@selector(coimConnectionDidFinishLoading:)]) {
        [delegate coimConnectionDidFinishLoading:connection];
    }
}
// coimotion SDK public methods
+ (void)initSDK:(void (^)(NSError *))errBlock
{
    if([plistFilePath isEqual:@""]){
        connectionProgress = nil;
        appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APP_KEY"];
        appCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APP_CODE"];
        if(appKey == nil || appCode == nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"App code and/or App key are not defined in budle"                                                           forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:ERR_LACK_APP_INFO userInfo:userInfo];
            errBlock(error);
            return;
        }
        baseURL = [[NSString alloc] initWithFormat:@"http://%@.coimapi.net/", appCode];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        plistFilePath = [documentsDirectory stringByAppendingString:@"/coimotion.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableDictionary *plistDict;
        if (![fileManager fileExistsAtPath: plistFilePath]) {//檢查檔案是否存在
            plistDict = [[NSMutableDictionary alloc] init];
            if ([plistDict writeToFile:plistFilePath atomically: YES]) {
                NSLog(@"writePlist success");
            }
            else {
                NSLog(@"writePlist fail");
            }
        }
    }
}

//private methods
+ (NSString *)getToken
{
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistFilePath];
    NSString *token = @"";
    if([dic objectForKey:@"token"] == nil)
        token = @"N/A";
    else
        token = [dic objectForKey:@"token"];
    return token;
}

+ (void)setToken:(NSString *)token
{
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:token ,@"token", nil];
    [dic writeToFile:plistFilePath atomically:YES];
}

+ (void)clearToken
{
    NSDictionary *dic = [NSDictionary new];
    [dic writeToFile:plistFilePath atomically:YES];
}

+ (NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

@end
