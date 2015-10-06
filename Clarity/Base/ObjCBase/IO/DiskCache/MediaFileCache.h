//
//  BrabbleImgDiskCache.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/18/13.
//
//

#import "AvatarFileCache.h"

@interface MediaFileCache : AvatarFileCache

+ (NSString *)name;
+ (NSString *)subDirName;

+ (NSString *)imagePathForNewsId:(NSInteger)newsId;
+ (NSString *)imagePathForSocialId:(NSString *)socialId;

@end
