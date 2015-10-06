//
//  ImageCacheInArrayItem.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageCacheRequest.h"

@interface ImageCacheItem : NSObject

@property (strong, nonatomic) ImageCacheRequest *request;
@property (strong, nonatomic) UIImage *image;

@end
