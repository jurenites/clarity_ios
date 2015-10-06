//
//  ImageCacheKey.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import <Foundation/Foundation.h>

@interface ImageCacheKey : NSObject <NSCopying>

- (instancetype)initWithType:(NSInteger)type identifier:(id)identifier;

@end
