//
//  BrabbleImgDiskCache.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/18/13.
//
//

#import "MediaFileCache.h"

static const NSInteger BBMediaFileCacheLimit = 800*1024*1024;
static const NSInteger BBMediaFileCacheTreshold = 400*1024*1024;

@implementation MediaFileCache

+ (NSString *)name
{
    return @"BrabbleImgCache";
}

+ (NSString *)subDirName
{
    return @"BrabbleImages";
}

- (instancetype)init
{
    return [super initWithPath:[[self class] subDirName]
                    cacheLimit:BBMediaFileCacheLimit
                     threshold:BBMediaFileCacheTreshold];
}

+ (NSString *)imagePathForNewsId:(NSInteger)newsId
{
    return [NSString stringWithFormat:@"news_%ld", (long)newsId];
}

+ (NSString *)imagePathForSocialId:(NSString *)socialId
{
    return [NSString stringWithFormat:@"social_%@", socialId];
}

@end
