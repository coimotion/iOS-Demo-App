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
NSString *const coiLoginURI = @"teaShop/account/login";
NSString *const coiSearchURI = @"teaShop/shops/search";
NSString *const coiCheckTokenURI = @"teaShop/account/profile";
NSString *const coiDetailURI = @"teaShop/shops/info";
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
    .detail = @"detail"
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
    .geID = @"geID",
    .ngID = @"ngID",
    .token = @"token",
    .addr = @"addr",
    .dspName = @"dspName",
    .doc = @"doc"
};

@end
