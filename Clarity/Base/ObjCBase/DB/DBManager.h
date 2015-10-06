//
//  DBManager.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/4/13.
//
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "NSArray+DB.h"
#import "DBHelper.h"
#import "UniqueNumber.h"

typedef void (^DbExecSyncFunc)(Database *db);
typedef id (^DbExecAsyncFunc)(Database *db);
typedef void (^DbOnAsyncComplete)(id res);
typedef void (^DbOnAsyncError)(NSError *error);
typedef id (^DbProcessFn)(id input);

@interface DBManager : NSObject

- (instancetype)initWithDBFileName:(NSString *)dbFileName;

- (BOOL)startDb:(NSError **)error;
- (void)recreateDb;

- (void)removeDatabaseFile;

- (NSError *)exec:(DbExecSyncFunc)fn;

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn;

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn
                  onSuccess:(DbOnAsyncComplete)onSuccess;

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn
                  onSuccess:(DbOnAsyncComplete)onSuccess
                    onError:(DbOnAsyncError)onError;

- (UniqueNumber *)execAsync:(DbExecAsyncFunc)fn
                   pipeline:(NSArray *)pipeline
                  onSuccess:(DbOnAsyncComplete)onSuccess
                    onError:(DbOnAsyncError)onError;

- (void)cancelRequest:(UniqueNumber *)reqId;
- (void)cancelRequests:(NSSet *)reqIds;

@end
