//
//  HttpError.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/19/14.
//
//

#import "HttpError.h"

@implementation HttpError

+ (instancetype)errorWithCode:(NSInteger)code
{
    return [self errorWithCode:code descr:[NSString stringWithFormat:@"HTTP error %ld", (long)code]];
}

@end
