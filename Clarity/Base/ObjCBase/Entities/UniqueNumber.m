//
//  UniqueNumber.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 6/4/14.
//
//

#import "UniqueNumber.h"

@interface UniqueNumber ()
{
    NSNumber *_num;
}
@end

@implementation UniqueNumber

- (instancetype)initWithNumber:(NSNumber *)num
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _num = num;
    return self;
}

- (id)uniqueId
{
    return _num;
}

- (NSNumber *)number
{
    return _num;
}

@end
