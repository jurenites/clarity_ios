//
//  InternalError.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/17/14.
//
//

#import "Error.h"

typedef enum {
    InternalErrorCellurarUploadDenied = 10,
    InternalErrorFBConnectCanceled,
    InternalErrorTWConnectCanceled
} InternalErrorCode;

@interface InternalError : Error

@end
