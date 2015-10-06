//
//  Error.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import "Error.h"

@implementation Error

- (instancetype)initWithCode:(NSInteger)code descr:(NSString *)descr
{
    return [super initWithDomain:@"com.brabble.error"
                            code:code
                        userInfo:@{NSLocalizedDescriptionKey: descr}];
}

+ (instancetype)errorWithCode:(NSInteger)code descr:(NSString *)descr
{
    return [[self alloc] initWithCode:code descr:descr];
}

+ (instancetype)errorWithDescr:(NSString *)descr
{
    return [[self alloc] initWithCode:0 descr:descr];
}

- (void)raise
{
    [NSException raise:@"Error" format:@"%@", self.localizedDescription];
}

- (ErrorType)type
{
    return ErrorTypeDefault;
}

@end
