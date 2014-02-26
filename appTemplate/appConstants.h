//
//  appConstants.h
//  appTemplate
//
//  Created by Mac on 14/2/25.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface appConstants : NSObject

extern NSString *const coiBaseURL;
extern NSString *const coiAppCode;
extern NSString *const coiLoginURI;
extern NSString *const coiSearchURI;
extern NSString *const coiCheckTokenURI;
extern NSString *const coiDetailURI;
extern NSString *const coiPlist;
extern NSString *const coiMethodPost;
extern NSString *const coiMethodGet;

struct requestKeysForCoimotionAPI{
    __unsafe_unretained NSString *lat;
    __unsafe_unretained NSString *lng;
    __unsafe_unretained NSString *addr;
    __unsafe_unretained NSString *accName;
    __unsafe_unretained NSString *passwd;
    __unsafe_unretained NSString *token;
    __unsafe_unretained NSString *detail;
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
};

extern const struct requestKeysForCoimotionAPI coiReqParams;
extern const struct responseKeysFromCoimotionAPI coiResParams;
@end
