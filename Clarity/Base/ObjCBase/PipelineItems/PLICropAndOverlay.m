//
//  PLICropAndOverlay.m
//  StaffApp
//
//  Created by stolyarov on 04/08/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "PLICropAndOverlay.h"
#import <CoreImage/CoreImage.h>
#import "CIContext+Shared.h"
#import "CIImage+AspectFill.h"

@interface PLICropAndOverlay ()
{
    CGSize _dstSize;
    CGFloat _addOverlay;
}
@end

@implementation PLICropAndOverlay

- (instancetype)initWithDstSize:(CGSize)size blackOverlay:(BOOL) addOverlay
{
    self = [super init];
    if (!self)
        return nil;
    
    _dstSize = size;
    _addOverlay = addOverlay;
    
    return self;
}


- (PipelineResult *)process:(id)input
{
    UIImage *img = [UIImage imageWithData:input];
    
    if (!img) {
        return [[PipelineResult alloc] initWithErrorDescr:@"PipelineItem error"];
    }
    
    CIImage *src = [CIImage imageWithCGImage:img.CGImage];
    
    UIImage *result = nil;
    
    if (_fromYoutube) {
        CGRect cropRect = CGRectMake(
                                     0,
                                     45.f,
                                     img.size.width,
                                     img.size.height-90.f);
        CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
        
        src = [CIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
    }
    
    result = [src aspectFillWithSize:_dstSize orientation:img.imageOrientation addOverlay:_addOverlay];
    
    return [[PipelineResult alloc] initWithResult:result];
}




@end
