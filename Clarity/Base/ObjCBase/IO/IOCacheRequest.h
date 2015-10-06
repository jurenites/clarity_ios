//
//  IOCacheRequest.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/17/14.
//
//

#import "IORequest.h"
#import "FileCacheRequest.h"

@interface IOCacheRequest : IORequest

- (instancetype)init;

@property (strong, nonatomic) FileCacheRequest *cache;

@end
