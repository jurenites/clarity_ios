//
//  ImageCacheImage.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageCacheRequest.h"
#import "ApiCanceler.h"

@interface ImageCacheImage : NSObject

- (instancetype)initWithRequest:(ImageCacheRequest *)item;

- (void)addScrollIndex:(NSInteger)pos;
- (void)removeScrollIndex:(NSInteger)pos;
- (void)clearIndexes;

- (NSSet *)getIndexesCopy;

- (BOOL)hasPosition:(NSInteger)position;
- (BOOL)hasIndexes;

@property (readonly, nonatomic) ImageCacheRequest *request;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) ApiCanceler *canceler;

@end
