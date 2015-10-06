//
//  DiskCache.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/18/13.
//
//

#import <Foundation/Foundation.h>
#import "FileCacheRequest.h"

@interface FileCache : NSObject

+ (NSString *)cacheDir;
+ (void)denyFileBackup:(NSString *)filePath;

- (instancetype)initWithPath:(NSString *)path
                  cacheLimit:(int64_t)cacheLimit
                   threshold:(int64_t)threshold;

//================== Thread safe methods =====================
- (NSMutableData *)loadFileWithName:(NSString *)fileName;
- (NSString *)findFileWithName:(NSString *)fileName;
- (NSMutableData *)loadFileWithRequest:(FileCacheRequest *)request;
- (NSString *)findFileWithRequest:(FileCacheRequest *)request;
- (NSString *)pathForFileName:(NSString *)fileName;
- (NSString *)getCachePath;
//--------------------------------------------------------------


//================ The rest methods are NOT thread safe ================
- (void)reload;
- (void)saveFile:(NSData *)file withName:(NSString *)name;
- (void)saveFile:(NSData *)file withRequest:(FileCacheRequest *)request;
- (void)saveFilePath:(NSString *)srcPath withRequest:(FileCacheRequest *)request;
- (NSTimeInterval)expiteTreshold;

- (void)deleteAllFiles;

//============= override methods ================
- (BOOL)isFilePathOnHold:(NSString *)filePath;
- (void)fileRemoved:(NSString* )fileName;
- (void)cacheWillTrim;
- (void)cacheDidTrim;


@property (atomic, assign) int64_t totalSize;

@end
