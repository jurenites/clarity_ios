//
//  AvatarFileCache.m
//  Brabble-iOSClient
//
//  Created by Alexey on 2/14/14.
//
//

#import "AvatarFileCache.h"
#import "AvatarCacheRequest.h"

static const NSInteger BBAvatarFileCacheLimit = 100*1024*1024;
static const NSInteger BBAvatarFileCacheTreshold = 50*1024*1024;

@implementation AvatarFileCache

+ (NSString *)name
{
    return @"AvatarFileCache";
}

+ (NSString *)subDirName
{
    return @"AvatarFileCache";
}

- (instancetype)init
{
    return [super initWithPath:[[self class] subDirName]
                    cacheLimit:BBAvatarFileCacheLimit
                     threshold:BBAvatarFileCacheTreshold];
}

- (BOOL)isFileCachedWithRequest:(AvatarCacheRequest *)request
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self pathForFileName:request.fileName];
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    
    NSDate *fileModified = attrs[NSFileCreationDate];
    
    if (!attrs || !fileModified) {
        return NO;
    }
    
//    // request.modified may be in future when avatar has been changed
//    // and we need to wait for about 15 minutes, while avatar updating on server
//    if (request.modified && [[NSDate date] timeIntervalSinceDate:fileModified] > 0) {
//        if ([request.modified timeIntervalSinceDate:fileModified] > self.expiteTreshold) {
//            return NO;
//        }
//    }
    
    if (request.modified
        && [request.modified timeIntervalSinceDate:fileModified] > self.expiteTreshold) {
        return NO;
    }
    
    return YES;
}

- (NSString *)findFileWithRequest:(AvatarCacheRequest *)request
{
    NSAssert([request isKindOfClass:[AvatarCacheRequest class]], @"");
    
    if ([self isFileCachedWithRequest:request]) {
        return [super findFileWithRequest:request];
    }
    
    return nil;
}

- (NSMutableData *)loadFileWithRequest:(AvatarCacheRequest *)request
{
    NSAssert([request isKindOfClass:[AvatarCacheRequest class]], @"");
    
    if ([self isFileCachedWithRequest:request]) {
        return [super loadFileWithRequest:request];
    }

    return nil;
}

- (void)saveFile:(NSData *)file withRequest:(AvatarCacheRequest *)request
{
    NSAssert([request isKindOfClass:[AvatarCacheRequest class]], @"");
    
    [super saveFile:file withRequest:request];
    
    if (request.modified) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm setAttributes:@{NSFileCreationDate:request.modified}
             ofItemAtPath:[self pathForFileName:request.fileName]
                    error:nil];
    }
}

- (BOOL)isFilePathOnHold:(NSString *)filePath
{
    NSString *fileName = [filePath lastPathComponent];
    
    return
            [super isFilePathOnHold:filePath]
        ||  [fileName isEqualToString:BBCurrUserAvatarFileName]
        ||  [fileName isEqualToString:BBCurrUserCoverFileName];
}

- (void)updateImage:(NSData *)image withFileName:(NSString *)fileName modifyDate:(NSDate *)modifyDate
{
    AvatarCacheRequest *req = [AvatarCacheRequest new];
    
    req.fileName = fileName;
    req.modified = modifyDate;
    
    [self saveFile:image withRequest:req];
}

+ (NSString *)avatarNameForStaffUserId:(NSString *)userId
{
    return [NSString stringWithFormat:@"staff_user_%@", userId];
}

+ (NSString *)avatarNameForUserId:(NSInteger)userId
{
    return [NSString stringWithFormat:@"user_%ld", (long)userId];
}

+ (NSString *)avatarNameFromUrl:(NSString *)avatarUrl
{
    return [avatarUrl componentsSeparatedByString:@"/"].lastObject;
}
@end
