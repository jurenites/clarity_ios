//
//  CIImage+Crop.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/6/14.
//
//

#import "CIImage+Crop.h"
#import "CIContext+Shared.h"
#import "UIImage+Transform.h"

@implementation CIImage (Crop)

- (UIImage *)cropWithNormalizedSrcRect:(CGRect)srcRect
                              dstWidth:(CGFloat)dstWidth
                           orientation:(UIImageOrientation)orientation
{
    const CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize actualSrcSize = self.extent.size;
    const CGSize srcSize = [UIImage convertSize:actualSrcSize forOrientation:orientation];
    const CGFloat scale = (dstWidth * screenScale) / (srcRect.size.width * srcSize.width);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformScale(transform, scale, scale);
    
    if (orientation != UIImageOrientationUp) {
        transform = [UIImage transform:transform withOrientation:orientation];
    }
    
    transform = CGAffineTransformTranslate(
       transform,
       -0.5f * actualSrcSize.width,
       -0.5f * actualSrcSize.height);
    
    CIContext *ctx = [CIContext shared];
    CIImage *output = nil;
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    
    [transformFilter setValue:self forKey:kCIInputImageKey];
    [transformFilter setValue:[NSValue valueWithBytes:&transform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    output = [transformFilter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImg = [ctx createCGImage:output
                                 fromRect:CGRectMake(
                                     ((-0.5f + srcRect.origin.x) * srcSize.width) * scale,
                                     ((0.5f - srcRect.origin.y) * srcSize.height - srcSize.height * srcRect.size.height) * scale,
                                     srcRect.size.width * srcSize.width * scale,
                                     srcRect.size.height * srcSize.height * scale)];
    
    UIImage *result = [UIImage imageWithCGImage:cgImg
                                          scale:1
                                    orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return result;
}

@end
