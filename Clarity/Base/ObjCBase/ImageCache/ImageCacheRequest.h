//
//  ImageCacheItem.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/5/13.
//
//

#import <Foundation/Foundation.h>

typedef int ImageCacheItemType;

@interface ImageCacheRequest : NSObject

@property (strong, nonatomic) id<NSCopying, NSObject> key;
@property (strong, nonatomic) NSDate *updated;

@end
