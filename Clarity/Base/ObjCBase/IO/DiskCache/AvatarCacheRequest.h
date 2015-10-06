//
//  AvaterCacheRequest.h
//  Brabble-iOSClient
//
//  Created by Alexey on 2/14/14.
//
//

#import "FileCacheRequest.h"

@interface AvatarCacheRequest : FileCacheRequest

@property (strong, nonatomic) NSDate *modified;

@end
