//
//  IOOperation.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/8/13.
//
//

#import <Foundation/Foundation.h>
#import "FileCache.h"
#import "IOQueueItem.h"
#import "NonTypedUniqueObject.h"

@class IORequest;
@class IOOperation;

//------------------------------------
@protocol IOOperationDelegate <NSObject>
@required
- (void)ioOperationSucceeded:(IOOperation *)operation withData:(NSData *)data httpCode:(NSInteger)httpCode;
- (void)ioOperationSucceeded:(IOOperation *)operation withFilePath:(NSString *)filePath httpCode:(NSInteger)httpCode;
- (void)ioOperationFailed:(IOOperation *)operation withError:(NSError *)error;
- (void)ioOperationNeedNetwork:(IOOperation *)operation;
- (FileCache *)ioOperation:(IOOperation *)operation cacheForName:(NSString*)name;
- (BOOL)ioOperationInOnline;

@end

//-----------------------------------
@interface IOOperation : NonTypedUniqueObject <IOQueueItem>

- (instancetype)initWithDelegate:(id<IOOperationDelegate>)delegate;

- (void)perform;
- (void)startNetworkOperation;
- (void)cancel;

- (void)needSpinner;
- (void)discardSpinner;

@property (readonly, nonatomic) IORequest *request;
@property (weak, readonly, nonatomic) id<IOOperationDelegate> delegate;

@end
