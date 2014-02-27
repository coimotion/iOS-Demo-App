//
//  appConstants.m
//  appTemplate
//
//  Created by Mac on 14/2/25.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "appConstants.h"

@implementation appConstants
NSString *const coiBaseURL = @"http://api.coimotion.com";
NSString *const coiAppCode = @"demoApp";
NSString *const coiLoginURI = @"drinks/account/login";
NSString *const coiRegisterURI = @"drinks/account/register";
NSString *const coiActivateURI = @"drinks/account/activate";
NSString *const coiSearchURI = @"drinks/shops/search";
NSString *const coiCheckTokenURI = @"drinks/account/profile";
NSString *const coiDetailURI = @"drinks/shops/info";
NSString *const coiPlist = @"/app.plist";
NSString *const coiMethodPost = @"POST";
NSString *const coiMethodGet = @"GET";

const struct requestKeysForCoimotionAPI coiReqParams = {
    .lat = @"lat",
    .lng = @"lng",
    .addr = @"addr",
    .accName = @"accName",
    .passwd = @"passwd",
    .token = @"token",
    .detail = @"detail",
    .passwd2 = @"passwd2"
};

const struct responseKeysFromCoimotionAPI coiResParams = {
    .errCode = @"errCode",
    .message = @"message",
    .value = @"value",
    .list = @"list",
    .latitude = @"latitude",
    .longitude = @"longitude",
    .title = @"title",
    .summary = @"summary",
    .body = @"body",
    .geID = @"geID",
    .ngID = @"ngID",
    .token = @"token",
    .addr = @"addr",
    .dspName = @"dspName",
    .doc = @"doc",
    .actID = @"actID"
};

@end
