//
//  appUtil.h
//  appTemplate
//
//  Created by Mac on 14/2/20.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#define CHECK_TOKEN_CONNECTION_LABEL @"checkTokenConn"
#define LOGIN_CONNECTION_LABEL @"loginConn"
#define SEARCH_CONNECTION_LABEL @"searchConn"
#define DETAIL_CONNECTION_LABEL @"detailConn"
#define REGISTER_CONNECTION_LABEL @"registerConn"
#define ACTIVATE_CONNECTION_LABEL @"activateConn"
#define DOC_CONNECTION_LABEL @"docConn"
#define TOP_OF_BUTTON 253
#define TOP_OF_INDICATOR 265
#define SHIFT (253-215)

#define CELL_IDENTIFIER @"cell"
#define SEARCH_ERROR @"搜尋錯誤"
#define LOGIN_ERROR @"登入錯誤"
#define REGISTER_ERROR @"註冊錯誤"
#define DETAIL_ERROR @"資訊錯誤"
#define LIST_TITLE @"店家一覽"
#define MAP_TITLE @"店家地圖"
#define RIGHT_BUTTON_TITLE_MAP @"登出"
#define LEFT_BUTTON_TITLE_MAP @"目前位置"
#define RIGHT_BUTTON_TITLE_LIST @"登出"
#define LEFT_BUTTON_TITLE_LIST @"登出"

@interface appUtil : NSObject{}
extern NSString *const coimBaseURL;
extern NSString *const coimLoginURI;
extern NSString *const coimRegisterURI;
extern NSString *const coimActivateURI;
extern NSString *const coimLogoutURI;
extern NSString *const coimSearchURI;
extern NSString *const coimCheckTokenURI;
extern NSString *const coimDetailURI;
extern NSString *const coimDocURI;

struct requestKeysForCoimotionAPI{
    __unsafe_unretained NSString *lat;
    __unsafe_unretained NSString *lng;
    __unsafe_unretained NSString *addr;
    __unsafe_unretained NSString *accName;
    __unsafe_unretained NSString *passwd;
    __unsafe_unretained NSString *token;
    __unsafe_unretained NSString *detail;
    __unsafe_unretained NSString *passwd2;
    __unsafe_unretained NSString *appKey;
};


struct responseKeysFromCoimotionAPI{
    __unsafe_unretained NSString *errCode;
    __unsafe_unretained NSString *message;
    __unsafe_unretained NSString *value;
    __unsafe_unretained NSString *list;
    __unsafe_unretained NSString *latitude;
    __unsafe_unretained NSString *longitude;
    __unsafe_unretained NSString *title;
    __unsafe_unretained NSString *summary;
    __unsafe_unretained NSString *geID;
    __unsafe_unretained NSString *ngID;
    __unsafe_unretained NSString *token;
    __unsafe_unretained NSString *addr;
    __unsafe_unretained NSString *dspName;
    __unsafe_unretained NSString *doc;
    __unsafe_unretained NSString *actID;
    __unsafe_unretained NSString *body;
};

extern const struct requestKeysForCoimotionAPI coimReqParams;
extern const struct responseKeysFromCoimotionAPI coimResParams;

@property (nonatomic, retain)NSString *token;
@property (nonatomic, retain)NSString *userName;
@property (nonatomic, retain)NSDictionary *shopMenuList;

//+ (id)sharedUtil;
+ (void)setRootWindowView:(UIViewController *)VC;
//- (NSURLRequest *)getHttpRequestByMethod:(NSString *)method toURL:(NSString *)URL useData:(NSString *)data;
//- (void)logout;
+ (void)enterApp;
+ (void)enterLogin;
//- (void)saveObject:(id)obj forKey:(NSString *)key toPlist:(NSString *)fileName;
//- (id)readObjectForKey:(NSString *)key fromPlist:(NSString *)fileName;
@end
