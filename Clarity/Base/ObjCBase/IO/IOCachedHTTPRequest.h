//
//  IOCachedHTTPRequest.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import "IOHTTPRequest.h"
#import "AvatarCacheRequest.h"

static const NSInteger HTTPCodeCached = 0;

@interface IOCachedHTTPRequest : IOHTTPRequest

- (instancetype)init;

@property (strong, nonatomic) AvatarCacheRequest *cache;
@property (assign, nonatomic) BOOL offlineMode;
@property (assign, nonatomic) BOOL failIfInCache;

@end
