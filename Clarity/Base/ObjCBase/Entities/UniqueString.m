//
//  UniqueString.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 6/4/14.
//
//

#import "UniqueString.h"

@interface UniqueString ()
{
    NSString *_string;
}
@end

@implementation UniqueString

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _string = string;
    return self;
}

- (id)uniqueId
{
    return _string;
}

- (NSString *)string
{
    return _string;
}

@end
