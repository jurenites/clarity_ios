//
//  NetworkError.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/17/14.
//
//

#import "Error.h"

typedef enum {
    NetworkErrorNoDiscovery = 9000,
    NetworkErrorOffline,
    NetworkErrorOther
} NetworkErrorCode;

@interface NetworkError : Error

+ (instancetype)errorWithCode:(NetworkErrorCode)code;
+ (instancetype)errorWithError:(NSError *)error;

@end
