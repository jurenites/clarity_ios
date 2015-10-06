//
//  IOHTTPOperation.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import "IOOperation.h"
#import "IOHTTPRequest.h"

@interface IOHTTPOperation : IOOperation

- (IOHTTPOperation *)initWithRequest:(IOHTTPRequest *)request
                            delegate:(id<IOOperationDelegate>)delegate;

- (void)perform;
- (void)startNetworkOperation;
- (void)cancel;

- (BOOL)canCacheIt;

@end