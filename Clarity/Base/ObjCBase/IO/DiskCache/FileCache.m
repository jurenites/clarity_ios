//
//  DiskCache.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/18/13.
//
//

#import "FileCache.h"
#import "TextUtils.h"
#import "NSThread+Utils.h"

static const int ExpireTreshold = 2;

@interface DiskCacheFile : NSObject

@property (assign, nonatomic) uint64_t size;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDate *accessDate;

@end

@implementation DiskCacheFile

@end

//---------------------------------------
@interface FileCache ()
{
    int64_t _cacheLimit;
    int64_t _cacheThreshold;
    
    NSMutableSet *_filesOnHold;
}

- (void)checkCacheLimit;
- (void)deleteTemporaryFiles;

@property (atomic, strong) NSString *path;
@property (atomic, assign) BOOL deletingInProgress;

@end

@implementation FileCache

+ (NSString *)cacheDir
{
    return [TextUtils getCachesDir];
}

+ (void)denyFileBackup:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    
    [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
}

- (instancetype)initWithPath:(NSString *)path
                  cacheLimit:(int64_t)cacheLimit
                   threshold:(int64_t)threshold;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.path = [[[self class] cacheDir] stringByAppendingPathComponent:path];
    _cacheLimit = cacheLimit;
    _cacheThreshold = threshold;
    _filesOnHold = [NSMutableSet set];
    
    self.totalSize = 0;
    
    if (_cacheThreshold >= _cacheLimit) {
        [NSException raise:@"Panic!" format:@"DiskCache threshold >= cacheLimit"];
    }
    
    return self;
}

- (NSString *)pathForFileName:(NSString* )fileName
{
    return [self.path stringByAppendingPathComponent:fileName];
}

- (NSString *)getCachePath
{
    return self.path;
}

- (void)checkDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:self.path]) {
        [self reload];
    }
}

- (void)reload
{
    [self deleteTemporaryFiles];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:self.path
                              withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    int64_t totalSize = 0;
    
    NSArray *list = [fm contentsOfDirectoryAtURL:[[NSURL alloc] initFileURLWithPath:self.path]
                      includingPropertiesForKeys:@[NSURLFileSizeKey]
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                           error:nil];

    for(NSURL *url in list) {
        NSNumber *fileSize = nil;
        
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        
        if (fileSize) {
            totalSize += fileSize.unsignedLongLongValue;
        }
    }
    
    self.totalSize = totalSize;
}

- (NSTimeInterval)expiteTreshold
{
    return ExpireTreshold;
}

- (NSMutableData *)loadFileWithName:(NSString *)fileName
{
    return [NSMutableData dataWithContentsOfFile:[self pathForFileName:fileName]];
}

- (NSString *)findFileWithName:(NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self pathForFileName:fileName];
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    
    return attrs ? filePath : nil;
}

- (void)saveFile:(NSData *)file withName:(NSString *)name
{
    FileCacheRequest *req = [FileCacheRequest new];
    
    req.fileName = name;
    [self saveFile:file withRequest:req];
}

- (NSMutableData *)loadFileWithRequest:(FileCacheRequest *)request
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self pathForFileName:request.fileName];
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    
    if (!attrs) {
        return nil;
    }

    [fm setAttributes:@{NSFileModificationDate : [NSDate date]}
         ofItemAtPath:filePath
                error:nil];
    
    return [NSMutableData dataWithContentsOfFile:filePath];
}

- (NSString *)findFileWithRequest:(FileCacheRequest *)request
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self pathForFileName:request.fileName];
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    
    if (!attrs) {
        return nil;
    }
    
    [fm setAttributes:@{NSFileModificationDate : [NSDate date]}
         ofItemAtPath:filePath
                error:nil];
    
    return filePath;
}

- (void)saveFile:(NSData *)file withRequest:(FileCacheRequest *)request
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self pathForFileName:request.fileName];
    
    NSDictionary *existingAttrs = [fm attributesOfItemAtPath:filePath error:nil];
    
    NSError *err = nil;
    
    if ([file writeToFile:filePath options:NSDataWritingAtomic error:&err]) {
        [fm setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:nil];
        [[self class] denyFileBackup:filePath];
        
        if (existingAttrs) {
            self.totalSize -= [existingAttrs[NSFileSize] unsignedLongLongValue];
        }
        
        self.totalSize += file.length;
    } else {
        [self checkDirectory];
    }
    
    [self checkCacheLimit];
}

- (void)saveFilePath:(NSString *)srcPath withRequest:(FileCacheRequest *)request
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self pathForFileName:request.fileName];
    NSDictionary *existingAttrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDictionary *srcAttrs = [fm attributesOfItemAtPath:srcPath error:nil];
    
    if (!srcAttrs) {
        return;
    }
    
    if (existingAttrs) {
        self.totalSize -= [existingAttrs[NSFileSize] unsignedLongLongValue];
        [fm removeItemAtPath:filePath error:nil];
    }
    
    if ([fm moveItemAtPath:srcPath toPath:filePath error:nil]) {
        [fm setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:nil];
        [[self class] denyFileBackup:filePath];
        
        self.totalSize += [srcAttrs[NSFileSize] unsignedLongLongValue];
        
        if (request.onHold) {
            [_filesOnHold addObject:filePath];
        }
    } else {
        [self checkDirectory];
    }
    
    [self checkCacheLimit];
}

- (BOOL)isFilePathOnHold:(NSString *)filePath
{
    return [filePath hasSuffix:@".tmp"] || [_filesOnHold containsObject:filePath];
}

- (void)checkCacheLimit
{
    if (self.totalSize < _cacheLimit || self.deletingInProgress)
        return;
    
    double t = CACurrentMediaTime();

    NSMutableArray *cachedList = [NSMutableArray array];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *list = [fm contentsOfDirectoryAtURL:[[NSURL alloc] initFileURLWithPath:self.path]
                      includingPropertiesForKeys:@[NSURLFileSizeKey, NSURLFileResourceTypeKey, NSURLContentModificationDateKey]
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                           error:nil];
    
    for (NSURL *url in list) {
        NSNumber *fileSize = nil;
        NSString *resType = nil;
        NSDate *accessDate = nil;
    
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        [url getResourceValue:&resType forKey:NSURLFileResourceTypeKey error:nil];
        [url getResourceValue:&accessDate forKey:NSURLContentModificationDateKey error:nil];
        
        if (!fileSize
            || !accessDate
            || ![resType isEqualToString: NSURLFileResourceTypeRegular]) {
            continue;
        }
        
        NSString *filePath = url.absoluteString;
        
        if ([filePath hasSuffix:@".tmp"]
            || [_filesOnHold containsObject:filePath]) {
            continue;
        }
        
        DiskCacheFile *cacheFile = [DiskCacheFile new];
        
        cacheFile.url = url;
        cacheFile.size = fileSize.unsignedLongLongValue;
        cacheFile.accessDate = accessDate;
        
        [cachedList addObject:cacheFile];
    }
    
    [cachedList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 accessDate] compare:[obj2 accessDate]];
    }];
    
    NSMutableArray *forDelete = [NSMutableArray array];
    
    int64_t totalSize = self.totalSize;
    
    while (totalSize > _cacheThreshold && cachedList.count) {
        DiskCacheFile *cacheFile = cachedList.firstObject;
        
        [cachedList removeObjectAtIndex:0];
        totalSize -= cacheFile.size;
        
        [forDelete addObject:cacheFile.url];
        [self fileRemoved:[cacheFile.url.absoluteString lastPathComponent]];
    }
    
    self.deletingInProgress = TRUE;
    
    [self cacheWillTrim];
    
    NSThread *currentThread = [NSThread currentThread];
    
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSURL *fileUrl in forDelete) {
                NSNumber *fileSize = nil;
                
                [fileUrl getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
                
                if (fileSize)
                    self.totalSize -= fileSize.unsignedLongLongValue;
            
                if (![[NSFileManager defaultManager]
                    removeItemAtURL:fileUrl
                    error:nil]) {
                    NSLog(@"Warning! Can not remove file %@", fileUrl.absoluteString);
                }
            }
            
            [currentThread performAsyncBlock:^{
                [self cacheDidTrim];
            }];
            
            self.deletingInProgress = FALSE;
            
            NSLog(@"Cache trimed %f", CACurrentMediaTime() - t);
        }
    );
}

- (void)deleteTemporaryFiles
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *list = [fm contentsOfDirectoryAtURL:[[NSURL alloc] initFileURLWithPath:self.path]
                      includingPropertiesForKeys:@[NSURLFileResourceTypeKey]
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                           error:&error];
    
    for (NSURL *url in list) {
        NSString *resType = nil;
        [url getResourceValue:&resType forKey:NSURLFileResourceTypeKey error:nil];
        
        if (![resType isEqualToString: NSURLFileResourceTypeRegular]) {
            continue;
        }
        
        if ([url.absoluteString hasSuffix:@".tmp"]) {
            [fm removeItemAtURL:url error:nil];
        }
    }
}

- (void)deleteAllFiles
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm removeItemAtPath:self.path error:nil];
    _filesOnHold = [NSMutableSet set];
    self.totalSize = 0;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:self.path
                              withIntermediateDirectories:TRUE
                                               attributes:nil
                                                    error:nil];
}

- (void)fileRemoved:(NSString *)fileName
{
}

- (void)cacheWillTrim
{
}

- (void)cacheDidTrim
{
}

@end
