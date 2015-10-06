//
//  DBManager.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/4/13.
//
//

#import "DBManager.h"
#import "NSError+IO.h"
#import "PipelineItem.h"
#import "InternalError.h"
#import "ApiRouter_Auth.h"
#import "TextUtils.h"
#import "Entity+DB.h"
//#import "User+DB.h"
//#import "Question+DB.h"
//#import "Answer+DB.h"
//#import "FlashUpdate+DB.h"
#import "AvatarInfo.h"
//#import "SocialItem+DB.h"
//#import "News+DB.h"
//#import "Event+DB.h"

static NSInteger AppDbVersion = 6;

static NSString * const DbDirName = @"LifeChurch";
static NSString * const CurrentDbVersionKey = @"CurrentDbVersionKey";

@interface DBManager ()
{
//=======syncronized===============
    uint64_t _reqId;
    NSMutableSet *_reqsForCancel;
    NSMutableSet *_reqsInProcessing;
//---------------------------------

    NSArray *_tableClasses;
    
    NSString *_dbFileName;
    NSString *_dbFilePath;
    Database *_db;
    
    dispatch_queue_t _dispQueue;
}

- (NSError *)setupDb;
- (void)logout;

- (void)callPipeline:(NSArray *)pipeline
               reqId:(UniqueNumber *)reqId
              result:(id)result
           onSuccess:(DbOnAsyncComplete)onSuccess
             onError:(DbOnAsyncError)onError;

- (BOOL)checkForCancel:(UniqueNumber *)reqId;
- (BOOL)checkForCancelAtExit:(UniqueNumber *)reqId;

@end

@implementation DBManager

- (instancetype)initWithDBFileName:(NSString *)dbFileName
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _reqsForCancel = [NSMutableSet set];
    _reqsInProcessing = [NSMutableSet set];
    
    _dbFileName = dbFileName;
    _dispQueue = dispatch_queue_create("com.brabble.db", NULL);
    
    _tableClasses = @[[AvatarInfo class]];
    
    /*
     [User class], [Question class], [Answer class], [FlashUpdate class],
     [AvatarInfo class], [SocialItem class], [Event class], [News class]
     */
    
    return self;
}

- (BOOL)isStructureError:(NSException *)ex
{
    return [ex.reason rangeOfString:@"column"].location != NSNotFound;
}

- (NSError *)exec:(DbExecSyncFunc)fn
{
    __block NSError *error = nil;

    dispatch_sync(_dispQueue, ^{
        @try {
            fn(_db);
        }
        @catch (NSException *ex) {
            if ([_db inTransaction]) {
                [_db rollback];
            }
            
            if ([self isStructureError:ex]) {
                [self logout];
            }
            
            error = [InternalError errorWithDescr:ex.reason];
        }
    });
    
    return error;
}

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn onSuccess:(DbOnAsyncComplete)onSuccess
{
   return [self execAsync:fn onSuccess:onSuccess onError:nil];
}

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn
{
    return [self execAsync:fn onSuccess:nil onError:nil];
}

- (void)callPipeline:(NSArray *)pipeline
               reqId:(UniqueNumber *)reqId
              result:(id)result
           onSuccess:(DbOnAsyncComplete)onSuccess
             onError:(DbOnAsyncError)onError
{
    PipelineItem *head = pipeline.firstObject;
    
    NSArray *tail = [pipeline subarrayWithRange:NSMakeRange(1, pipeline.count - 1)];
    
    PipelineContext *ctx =
        [[PipelineContext alloc]
            initWithOnSuccess:^(id result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self checkForCancelAtExit:reqId]) {
                        return;
                    }
                
                    if (onSuccess) {
                        onSuccess(result);
                    }
                 });
            }
            onError:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self checkForCancelAtExit:reqId]) {
                        return;
                    }
                    
                    if (onError) {
                        onError(error);
                    }
                 });
            }
            callOnPPLThread:^(void(^fn)()) {
                 dispatch_async(_dispQueue, fn);
            }
            restartRequest:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAssert(FALSE, @"Trying to restart db request");
                
                    if (onError)
                        onError([InternalError errorWithDescr:@"Trying to restart db request"]);
                 });
            }
        ];
    
    [head call:result pipelineTail:tail ctx:ctx];
}

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn
               pipeline:(NSArray *)pipeline
              onSuccess:(DbOnAsyncComplete)onSuccess
                onError:(DbOnAsyncError)onError
{
    UniqueNumber *reqId = nil;
    
    @synchronized(self) {
        reqId = [[UniqueNumber alloc] initWithNumber:@(++_reqId)];
        [_reqsInProcessing addObject:reqId];
    }
    
    dispatch_async(_dispQueue, ^{
        id res = nil;
        
        @try {
            res = fn(_db);
        }
        @catch (NSException *ex) {
            if ([_db inTransaction]) {
                [_db rollback];
            }
            
            if ([self isStructureError:ex]) {
                [self logout];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self checkForCancelAtExit:reqId]) {
                    return;
                }
            
                if (onError) {
                    onError([InternalError errorWithDescr:ex.reason]);
                }
            });
            return;
        }
        
        if ([self checkForCancel:reqId]) {
            return;
        }
        
        if (pipeline.count) {
            [self callPipeline:pipeline reqId:reqId result:res onSuccess:onSuccess onError:onError];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self checkForCancelAtExit:reqId]) {
                    return;
                }
            
                if (onSuccess)
                    onSuccess(res);
            });
        }
    });
    
    return reqId;
}

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn
              onSuccess:(DbOnAsyncComplete)onSuccess
                onError:(DbOnAsyncError)onError

{
    return [self execAsync:fn pipeline:nil onSuccess:onSuccess onError:onError];
}

- (void)cancelRequest:(UniqueNumber *)reqId
{
    @synchronized(self) {
        if ([_reqsInProcessing containsObject:reqId]) {
            [_reqsForCancel addObject:reqId];
        }
    }
}

- (void)cancelRequests:(NSSet *)reqIds
{
    @synchronized(self) {
        for (NSNumber *reqId in reqIds) {
            if ([_reqsInProcessing containsObject:reqId]) {
                [_reqsForCancel addObject:reqId];
            }
        }
    }
}

- (BOOL)checkForCancel:(UniqueNumber *)reqId
{
    @synchronized(self) {
        BOOL canceled = [_reqsForCancel containsObject:reqId];
        
        if (canceled) {
            [_reqsForCancel removeObject:reqId];
            [_reqsInProcessing removeObject:reqId];
        }
        
        return canceled;
    }
}

- (BOOL)checkForCancelAtExit:(UniqueNumber *)reqId
{
    @synchronized(self) {
        BOOL canceled = [_reqsForCancel containsObject:reqId];
        
        if (canceled) {
            [_reqsForCancel removeObject:reqId];
        }
        
        [_reqsInProcessing removeObject:reqId];
        return canceled;
    }
}

- (BOOL)startDb:(NSError **)error
{
    __block NSError *err = nil;
    
    dispatch_sync(_dispQueue, ^{
         err = [self setupDb];
    });
   
    if (error) {
        *error = err;
    }
    
    return err == nil;
}

static int BBLCollate(void *arg, int x_len, const void *x, int y_len, const void *y)
{
    NSString *x_str = [[NSString alloc] initWithBytes:x length:x_len encoding:NSUTF8StringEncoding];
    NSString *y_str = [[NSString alloc] initWithBytes:y length:y_len encoding:NSUTF8StringEncoding];
    
    return [x_str localizedCaseInsensitiveCompare:y_str];
}

- (void)removeDatabaseFile
{
    NSString *path = [[[TextUtils getAppSupportDir]
            stringByAppendingPathComponent:DbDirName]
                stringByAppendingPathComponent:_dbFileName];
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (BOOL)isHasTables
{
    FMResultSet *res = [_db exec:@[@"SELECT name FROM sqlite_master WHERE type = 'table' LIMIT 1"]];
    
    return [res next];
}

- (NSError *)setupDb
{
    NSString *dbDirPath = [[TextUtils getAppSupportDir] stringByAppendingPathComponent:DbDirName];
    
    _dbFilePath = [dbDirPath stringByAppendingPathComponent:_dbFileName];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:dbDirPath
                              withIntermediateDirectories:YES attributes:nil error:nil];
    
    _db = [[Database alloc] initWithPath:_dbFilePath];
    
    if (![_db open]) {
        return [InternalError errorWithDescr:@"Can not open database"];
    }
    
    [FileCache denyFileBackup:_dbFilePath];
    
    sqlite3_create_collation([_db sqliteHandle], "BBL", SQLITE_UTF8, NULL, BBLCollate);
    
    [_db makeFunctionNamed:@"ToLower"
        maximumArguments:1
        withBlock:^(sqlite3_context *context, int aargc, sqlite3_value **aargv) {
            @autoreleasepool {
                if (sqlite3_value_type(aargv[0]) == SQLITE_TEXT) {
                    const char *c = (const char *)sqlite3_value_text(aargv[0]);
                    NSString *s = [[NSString stringWithUTF8String:c] lowercaseString];
                    sqlite3_result_text(context, s.UTF8String, -1, SQLITE_TRANSIENT);
                } else {
                    sqlite3_result_null(context);
                }
            }
        }];
    
    [_db makeFunctionNamed:@"Less3Strings"
          maximumArguments:6
                 withBlock:^(sqlite3_context *context, int aargc, sqlite3_value **aargv) {
                     @autoreleasepool {
                         if (aargc == 6
                             && sqlite3_value_type(aargv[0]) == SQLITE_TEXT
                             && sqlite3_value_type(aargv[1]) == SQLITE_TEXT
                             && sqlite3_value_type(aargv[2]) == SQLITE_TEXT
                             && sqlite3_value_type(aargv[3]) == SQLITE_TEXT
                             && sqlite3_value_type(aargv[4]) == SQLITE_TEXT
                             && sqlite3_value_type(aargv[5]) == SQLITE_TEXT) {
                             
                             NSString *x1 = [NSString stringWithUTF8String:(const char *)sqlite3_value_text(aargv[0])];
                             NSString *y1 = [NSString stringWithUTF8String:(const char *)sqlite3_value_text(aargv[1])];
                             
                             NSString *x2 = [NSString stringWithUTF8String:(const char *)sqlite3_value_text(aargv[2])];
                             NSString *y2 = [NSString stringWithUTF8String:(const char *)sqlite3_value_text(aargv[3])];
                             
                             NSString *x3 = [NSString stringWithUTF8String:(const char *)sqlite3_value_text(aargv[4])];
                             NSString *y3 = [NSString stringWithUTF8String:(const char *)sqlite3_value_text(aargv[5])];
                             
                             NSComparisonResult r1 = [x1 localizedCaseInsensitiveCompare:y1];
                             
                             if (r1 == NSOrderedSame) {
                                 NSComparisonResult r2 = [x2 localizedCaseInsensitiveCompare:y2];
                                 
                                 if (r2 == NSOrderedSame) {
                                     NSComparisonResult r3 = [x3 localizedCaseInsensitiveCompare:y3];
                                     sqlite3_result_int64(context, r3 == NSOrderedAscending ? 1 : 0);
                                 } else {
                                     sqlite3_result_int64(context, r2 == NSOrderedAscending ? 1 : 0);
                                 }
                             } else {
                                 sqlite3_result_int64(context, r1 == NSOrderedAscending ? 1 : 0);
                             }
                             
                         } else {
                             sqlite3_result_null(context);
                         }
                     }
                 }];
    
    @try {
        [_db execUpdateWithString:@"VACUUM"];
        
        const BOOL hasTables = [self isHasTables];
        
        for (Class tb in _tableClasses) {
            [tb createTableInDb:_db];
        }
        
        if (!hasTables) {
            [[NSUserDefaults standardUserDefaults] setInteger:AppDbVersion forKey:CurrentDbVersionKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            NSInteger currDbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:CurrentDbVersionKey];
            
            if (currDbVersion < AppDbVersion) {
//                for (Class tb in _tableClasses) {
//                    [tb migrateTableInDb:_db fromVersion:currDbVersion toVersion:AppDbVersion];
//                }
                
                [self recreateDbImpl];
                
                [[NSUserDefaults standardUserDefaults] setInteger:AppDbVersion forKey:CurrentDbVersionKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    @catch (NSException *ex) {
        return [InternalError errorWithDescr:ex.reason];
    }
    
    return nil;
}

- (void)recreateDbImpl
{
    [_db close];
    [[NSFileManager defaultManager] removeItemAtPath:_dbFilePath error:nil];
    
    NSError *error = [self setupDb];
    
    if (error) {
        [NSException raise:@"Database panic" format:@"Panic! Panic! Panic! %@", error.localizedDescription];
    }
}

- (void)recreateDb
{
    dispatch_sync(_dispQueue, ^{
        [self recreateDbImpl];
    });
}

- (void)logout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ApiRouter shared] invalidateLogin];
    });
}

@end
