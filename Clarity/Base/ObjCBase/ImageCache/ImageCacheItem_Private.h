//
//  ImageCacheItem_Private.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/13/14.
//
//

#import "ImageCacheItem.h"
#import "ImageCacheImage.h"

@interface ImageCacheItem ()

@property (weak, nonatomic) ImageCacheImage *cachedImage;

@end
