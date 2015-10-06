//
//  AvatarFileCache.h
//  Brabble-iOSClient
//
//  Created by Alexey on 2/14/14.
//
//

#import "FileCache.h"

static NSString * const BBCurrUserAvatarFileName = @"curr_user_avatar";
static NSString * const BBCurrUserLargeAvatarFileName = @"curr_user_large_avatar";
static NSString * const BBCurrUserCoverFileName = @"curr_user_cover";

@interface AvatarFileCache : FileCache

+ (NSString *)name;
+ (NSString *)subDirName;

+ (NSString *)avatarNameForStaffUserId:(NSString *)userId;
+ (NSString *)avatarNameForUserId:(NSInteger)userId;
+ (NSString *)avatarNameFromUrl:(NSString *)avatarUrl;


- (void)updateImage:(NSData *)image withFileName:(NSString *)fileName modifyDate:(NSDate *)modifyDate;

@end
