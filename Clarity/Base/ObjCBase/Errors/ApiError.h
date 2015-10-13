//
//  ApiError.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/17/14.
//
//

#import "Error.h"

typedef enum {
    ApiErrorBadSessionToken = 1001,
    ApiErrorCustomMessage = 2001,
    ApiErrorSessionTokenExpired = 401
} ApiErrorCode;

@interface ApiError : Error


@end
