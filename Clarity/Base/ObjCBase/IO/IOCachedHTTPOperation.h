//
//  IOCachedHTTPOperation.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import "IOOperation.h"
#import "IOCachedHTTPRequest.h"

@interface IOCachedHTTPOperation : IOOperation

- (IOCachedHTTPOperation *)initWithRequest:(IOCachedHTTPRequest *)request
                                  delegate:(id<IOOperationDelegate>)delegate;

- (void)perform;
- (void)startNetworkOperation;
- (void)cancel;

@end
