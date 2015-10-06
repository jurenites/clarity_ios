//
//  PLITypeCheck.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/14/14.
//
//

#import "PLITypeCheck.h"

@interface PLITypeCheck ()
{
    Class _class;
}
@end

@implementation PLITypeCheck

+ (id)PLIIsDictionary
{
    return [[PLITypeCheck alloc] initWithClass:[NSDictionary class]];
}

+ (id)PLIIsArray
{
    return [[PLITypeCheck alloc] initWithClass:[NSArray class]];
}

- (instancetype)initWithClass:(Class)classObj
{
    self = [super init];
    if (!self)
        return nil;
    
    _class = classObj;
    
    return self;
}

- (PipelineResult *)process:(id)input
{
    if ([input isKindOfClass:_class]) {
        return [[PipelineResult alloc] initWithResult:input];
    }
    
    return [[PipelineResult alloc] initWithErrorDescr:@"Server API error. Types mismatch."];
}

@end
