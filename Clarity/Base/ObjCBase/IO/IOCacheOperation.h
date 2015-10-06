//
//  IOCacheOperation.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/17/14.
//
//

#import "IOOperation.h"
#import "IOCacheRequest.h"

@interface IOCacheOperation : IOOperation

- (instancetype)initWithRequest:(IOCacheRequest *)request
                       delegate:(id<IOOperationDelegate>)delegate;

@end
