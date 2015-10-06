//
//  InternalError.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/17/14.
//
//

#import "InternalError.h"

@implementation InternalError

- (ErrorType)type
{
    return ErrorTypeInternal;
}

@end
