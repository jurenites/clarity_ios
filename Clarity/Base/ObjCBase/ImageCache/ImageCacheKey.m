//
//  ImageCacheKey.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import "ImageCacheKey.h"

@interface ImageCacheKey ()

@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) id identifier;

@end

@implementation ImageCacheKey

- (instancetype)initWithType:(NSInteger)type identifier:(id)identifier
{
    self = [super init];
    if (!self)
        return nil;
    
    self.type = @(type);
    self.identifier = identifier;
    
    return self;
}

- (NSUInteger)hash
{
    return [self.type hash] ^ [self.identifier hash];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[ImageCacheKey class]]
        && [self.type isEqual:((ImageCacheKey *)object).type]
        && [self.identifier isEqual:((ImageCacheKey *)object).identifier];
}

- (id)copyWithZone:(NSZone *)zone
{
    ImageCacheKey *key = [[self class] allocWithZone:zone];
    
    key.type = [self.type copy];
    key.identifier = [self.identifier copy];
    
    return key;
}

@end
