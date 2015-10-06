//
//  ImageCacheRanges.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/13/14.
//
//

#import <Foundation/Foundation.h>

@interface ImageCacheRanges : NSObject

@property (assign, nonatomic) NSRange fullRange;
@property (assign, nonatomic) NSRange visibleRange;

@end
