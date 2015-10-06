//
//  ApiMethod.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/15/14.
//
//

#import <Foundation/Foundation.h>
#import "IOHTTPRequest.h"

typedef enum {
    AMSBrabble,
    AMSUser,
    AMSDownload,
    AMSUpload,
    AMSLogin,
    AMSFacebook,
    AMSTwitter,
} AMServer;


@interface ApiMethod : NSObject

//Using short names for convenient dictionary build
+ (instancetype)srv:(AMServer)server
             method:(HttpMethod)httpMethod
                url:(NSString *)url;

//Using short names for convenient dictionary build
+ (instancetype)method:(HttpMethod)httpMethod
                   url:(NSString *)url;

- (instancetype)initWithServer:(AMServer)server
                    httpMethod:(HttpMethod)httpMethod
                           url:(NSString *)url;

-(NSString *)buildUrlWithParams:(NSDictionary *)params;

@property (assign, readonly, nonatomic) AMServer server;
@property (assign, readonly, nonatomic) HttpMethod httpMethod;

@end
