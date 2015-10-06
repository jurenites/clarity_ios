//
//  NetworkError.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/17/14.
//
//

#import "NetworkError.h"
#import "NSObject+Api.h"

@implementation NetworkError

- (instancetype)initWithError:(NSError *)error
{
    return [super initWithDomain:@"com.brabble.error" code:error.code userInfo:error.userInfo];
}

+ (instancetype)errorWithCode:(NetworkErrorCode)code
{
    return [self errorWithCode:code descr:[self codeToName:code]];
}

+ (instancetype)errorWithError:(NSError *)error
{
    return [[self alloc] initWithError:error];
}


+ (NSString *)codeToName:(NetworkErrorCode)code
{
    static NSDictionary *codeNames = nil;
    
    if (!codeNames) {
        codeNames = @{
            @(NetworkErrorNoDiscovery) : @"No discovery received",
            @(NetworkErrorOffline) : @"In offline mode",
            @(NetworkErrorOther) : NSLocalizedString(@"An error occurred while connecting to the server. Please try again.", nil)};
    }
    
    return ToString(codeNames[@(code)]);
}

@end
