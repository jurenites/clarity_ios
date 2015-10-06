//
//  CIImage+Crop.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/5/14.
//
//

#import "CIImage+AspectFill.h"
#import "CIContext+Shared.h"
#import "UIImage+Transform.h"
#import "UIImage+Utils.h"
#import <ImageIO/ImageIO.h>
#import "DeviceHardware.h"

static const CGFloat BBCoverGradientBegin = 0.5;

@implementation CIImage (AspectFill)

- (CGAffineTransform)aspectFillTransformWithSize:(CGSize)size orientation:(UIImageOrientation)orientation
{
    const CGSize dstSize = size;
    const CGSize actualSrcSize = self.extent.size;
    CGSize displaySrcSize = actualSrcSize;
    
    if (orientation != UIImageOrientationUp) {
        displaySrcSize = [UIImage convertSize:actualSrcSize forOrientation:orientation];
    }
    
    const CGFloat srcAspect = displaySrcSize.width / displaySrcSize.height;
    const CGFloat dstAspect = dstSize.width / dstSize.height;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGFloat scale =
            (dstAspect > srcAspect)
        ?   (dstSize.width / displaySrcSize.width)
        :   (dstSize.height / displaySrcSize.height);
    
    
    transform = CGAffineTransformScale(transform, scale, scale);
    
    if (orientation != UIImageOrientationUp) {
        transform = [UIImage transform:transform withOrientation:orientation];
    }
    
    transform = CGAffineTransformTranslate(
       transform,
       -0.5f * actualSrcSize.width,
       -0.5f * actualSrcSize.height);
    
    return transform;
}

- (CGAffineTransform)headAspectFillTransformToSize:(CGSize)size
                                 normalizedHeadPos:(CGPoint)normalizedHeadPos
                                       orientation:(UIImageOrientation)orientation
{
    const CGSize dstSize = size;
    const CGSize actualSrcSize = self.extent.size;
    CGSize displaySrcSize = actualSrcSize;
    
    if (orientation != UIImageOrientationUp) {
        displaySrcSize = [UIImage convertSize:actualSrcSize forOrientation:orientation];
    }
    
    const CGFloat srcAspect = displaySrcSize.width / displaySrcSize.height;
    const CGFloat dstAspect = dstSize.width / dstSize.height;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGFloat scale =
            (dstAspect > srcAspect)
        ?   (dstSize.width / displaySrcSize.width)
        :   (dstSize.height / displaySrcSize.height);
    
    if (dstAspect > srcAspect) {
        CGFloat yShift = MAX(MIN(-displaySrcSize.height * normalizedHeadPos.y * scale,
                                 displaySrcSize.height * scale * 0.5f - 0.5f * dstSize.height),
                             -displaySrcSize.height * scale * 0.5f + 0.5f * dstSize.height);
        
        transform = CGAffineTransformTranslate(transform, 0, yShift);
    } else {
        CGFloat xShift = MAX(MIN(-displaySrcSize.width * normalizedHeadPos.x * scale,
                                 displaySrcSize.width * scale * 0.5f - 0.5f * dstSize.width),
                             -displaySrcSize.width * scale * 0.5f + 0.5f * dstSize.width);
        
        transform = CGAffineTransformTranslate(transform, xShift, 0);
    }
    
    transform = CGAffineTransformScale(transform, scale, scale);
    
    if (orientation != UIImageOrientationUp) {
        transform = [UIImage transform:transform withOrientation:orientation];
    }
    
    transform = CGAffineTransformTranslate(transform,
                                           -0.5f * actualSrcSize.width,
                                           -0.5f * actualSrcSize.height);
    
    return transform;
    
}

- (UIImage *)aspectFillImplWithDstSize:(CGSize)dstSize screenScale:(CGFloat)screenScale transform:(CGAffineTransform)transform
{
    CIContext *ctx = [CIContext shared];
    CIImage *output = nil;
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    
    [transformFilter setValue:self forKey:kCIInputImageKey];
    [transformFilter setValue:[NSValue valueWithBytes:&transform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    output = [transformFilter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImg = [ctx createCGImage:output
                                 fromRect:CGRectMake(-0.5f*dstSize.width,
                                                     -0.5f*dstSize.height,
                                                     dstSize.width,
                                                     dstSize.height)];
    
    UIImage *result = [UIImage imageWithCGImage:cgImg
                                          scale:screenScale
                                    orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return [result removeAlpha];
}

- (UIImage *)aspectFillWithSize:(CGSize)size orientation:(UIImageOrientation)orientation
{
    const CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize dstSize = CGSizeMake(size.width * screenScale, size.height * screenScale);

    return [self aspectFillImplWithDstSize:dstSize
                               screenScale:screenScale
                                 transform:[self aspectFillTransformWithSize:dstSize orientation:orientation]];
}

- (UIImage *)aspectFillWithSize:(CGSize)size
{
    return [self aspectFillWithSize:size orientation:UIImageOrientationUp];
}

- (UIImage *)headAspectFillWithSize:(CGSize)size
                  normalizedHeadPos:(CGPoint)normalizedHeadPos
                        orientation:(UIImageOrientation)orientation
{
    const CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize dstSize = CGSizeMake(size.width * screenScale, size.height * screenScale);
    
    return [self aspectFillImplWithDstSize:dstSize
                               screenScale:screenScale
                                 transform:[self headAspectFillTransformToSize:dstSize
                                                             normalizedHeadPos:normalizedHeadPos
                                                                   orientation:orientation]];
}

- (UIImage *)aspectFillWithSize:(CGSize)size
                    orientation:(UIImageOrientation)orientation
                     blurRadius:(CGFloat)blurRadius
{
    const CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize dstSize = CGSizeMake(size.width * screenScale, size.height * screenScale);

    CGAffineTransform transform = [self aspectFillTransformWithSize:dstSize orientation:orientation];
    
    CIContext *ctx = [CIContext shared];
    CIImage *output = nil;
    
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    
    [transformFilter setValue:self forKey:kCIInputImageKey];
    [transformFilter setValue:[NSValue valueWithBytes:&transform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    output = [transformFilter valueForKey:kCIOutputImageKey];
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    [blurFilter setValue:output forKey:kCIInputImageKey];
    [blurFilter setValue:[NSNumber numberWithFloat:blurRadius] forKey:@"inputRadius"];
    output = [blurFilter valueForKey:kCIOutputImageKey];
        
    CIFilter *darkerFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    CIColor *color = [CIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [darkerFilter setValue:[CIImage imageWithColor:color] forKey:kCIInputImageKey];
    [darkerFilter setValue:output forKey:kCIInputBackgroundImageKey];
    output = [darkerFilter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImg = [ctx createCGImage:output
                                 fromRect:CGRectMake(
                                     -0.5f*dstSize.width,
                                     -0.5f*dstSize.height,
                                     dstSize.width,
                                     dstSize.height)];
    
    UIImage *result = [UIImage imageWithCGImage:cgImg
                                          scale:screenScale
                                    orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return [result removeAlpha];
}

- (UIImage *)aspectFillForListViewWithWidth:(CGFloat)width
{
    const CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize srcSize = self.extent.size;
    const CGFloat srcAspect = srcSize.width / srcSize.height;
    
    CGSize dstSize = CGSizeZero;
    CGFloat dstAspect = 1.0f;
    
    if (srcAspect > 1.0f) { // fit to width
        dstSize.width = width * screenScale;
        dstSize.height = round(width / srcAspect) * screenScale;
        dstAspect = srcAspect;
    } else { // crop to square
        dstSize.width = width * screenScale;
        dstSize.height = dstSize.width;
        dstAspect = 1.0f;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGFloat scale =
            (dstAspect > srcAspect)
        ?   (dstSize.width / srcSize.width)
        :   (dstSize.height / srcSize.height);
    
    transform = CGAffineTransformScale(transform, scale, scale);
    
    transform = CGAffineTransformTranslate(
       transform,
       -0.5f * srcSize.width,
       -0.5f * srcSize.height);
    
    CIContext *ctx = [CIContext shared];
    CIImage *output = nil;
    
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    
    [transformFilter setValue:self forKey:kCIInputImageKey];
    [transformFilter setValue:[NSValue valueWithBytes:&transform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    output = [transformFilter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImg = [ctx createCGImage:output
                                 fromRect:CGRectMake(
                                     -0.5f * dstSize.width,
                                     -0.5f * dstSize.height,
                                     dstSize.width,
                                     dstSize.height)];
    
    UIImage *result = [UIImage imageWithCGImage:cgImg
                                          scale:screenScale
                                    orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return [result removeAlpha];
}

- (UIImage *)aspectFillWithSize:(CGSize)size
                    orientation:(UIImageOrientation)orientation
                         addOverlay:(BOOL)addOverlay
{
    const CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize dstSize = CGSizeMake(size.width * screenScale, size.height * screenScale);
    
    CGAffineTransform transform = [self aspectFillTransformWithSize:dstSize orientation:orientation];
    
    CIContext *ctx = [CIContext shared];
    CIImage *output = nil;
    
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    
    [transformFilter setValue:self forKey:kCIInputImageKey];
    [transformFilter setValue:[NSValue valueWithBytes:&transform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    output = [transformFilter valueForKey:kCIOutputImageKey];
    
    
    if (addOverlay) {
        CIFilter *darkerfilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
        CIColor *color = [CIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [darkerfilter setValue:[CIImage imageWithColor:color] forKey:kCIInputImageKey];
        [darkerfilter setValue:output forKey:kCIInputBackgroundImageKey];
        output = [darkerfilter valueForKey:kCIOutputImageKey];
    }
    
    CGImageRef cgImg = [ctx createCGImage:output
                                 fromRect:CGRectMake(
                                     -0.5f * dstSize.width,
                                     -0.5f * dstSize.height,
                                     dstSize.width,
                                     dstSize.height)];
    
    UIImage *result = [UIImage imageWithCGImage:cgImg
                                          scale:screenScale
                                    orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return [result removeAlpha];
}

- (UIImage *)processCoverPhotoWithWidth:(CGFloat)width
                            orientation:(UIImageOrientation)orientation
                             blurRadius:(CGFloat)blurRadius
                               gradient:(BOOL)gradient
{
    const CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize dstSize = CGSizeMake(width * screenScale, width * screenScale);
    
    CGAffineTransform transform = [self aspectFillTransformWithSize:dstSize orientation:orientation];
    
    CIContext *ctx = [CIContext shared];
    CIImage *output = nil;
    
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    
    [transformFilter setValue:self forKey:kCIInputImageKey];
    [transformFilter setValue:[NSValue valueWithBytes:&transform
                                             objCType:@encode(CGAffineTransform)]
                       forKey:@"inputTransform"];
    
    output = [transformFilter valueForKey:kCIOutputImageKey];
    
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:output forKey:kCIInputImageKey];
    [blurFilter setValue:[NSNumber numberWithFloat:blurRadius] forKey:@"inputRadius"];
    output = [blurFilter valueForKey:kCIOutputImageKey];
    
    CIFilter *darkerfilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    CIColor *color = [CIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [darkerfilter setValue:[CIImage imageWithColor:color] forKey:kCIInputImageKey];
    [darkerfilter setValue:output forKey:kCIInputBackgroundImageKey];
    output = [darkerfilter valueForKey:kCIOutputImageKey];
    
    if (gradient) {
        CIFilter *gradient = [CIFilter filterWithName:@"CILinearGradient"];
        CIVector *gradientFrom = [CIVector vectorWithX:0 Y:(0.5f * dstSize.height - dstSize.height * BBCoverGradientBegin)];
        CIVector *gradientTo = [CIVector vectorWithX:0 Y:-0.5f * dstSize.height];
        
        [gradient setValue:[CIColor colorWithRed:0 green:0 blue:0 alpha:0] forKey:@"inputColor0"];
        [gradient setValue:[CIColor colorWithRed:0 green:0 blue:0 alpha:1] forKey:@"inputColor1"];
        [gradient setValue:gradientFrom forKey:@"inputPoint0"];
        [gradient setValue:gradientTo forKey:@"inputPoint1"];
        
        CIFilter *gradientOver = [CIFilter filterWithName:@"CISourceOverCompositing"];
        [gradientOver setValue:[gradient valueForKey:kCIOutputImageKey] forKey:kCIInputImageKey];
        [gradientOver setValue:output forKey:kCIInputBackgroundImageKey];
        output = [gradientOver valueForKey:kCIOutputImageKey];
    }
    
    CGImageRef cgImg = [ctx createCGImage:output
                                 fromRect:CGRectMake(
                                                     -0.5f * dstSize.width,
                                                     -0.5f * dstSize.height,
                                                     dstSize.width,
                                                     dstSize.height)];
    
    UIImage *result = [UIImage imageWithCGImage:cgImg
                                          scale:screenScale
                                    orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return [result removeAlpha];
}

- (CGPoint)getHeadPosWithOrientation:(UIImageOrientation)orientation
{
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
    
    NSArray *features = [detector featuresInImage:self
                options:@{CIDetectorImageOrientation : @(orientation)}];
    
    CIFaceFeature *face = features.firstObject;
    
    if (!face || !face.hasLeftEyePosition || !face.hasRightEyePosition || !face.hasMouthPosition) {
        return CGPointZero;
    }
    
    CGPoint absFaceCenter = CGPointZero;
    
    if (YES){//[BBDeviceHardware lowerThaniOS7]) {
        absFaceCenter = CGPointMake(face.leftEyePosition.x + 0.5f * (face.rightEyePosition.x - face.leftEyePosition.x),
                                    face.mouthPosition.y + 0.9f * (face.leftEyePosition.y - face.mouthPosition.y));
    } else {
        absFaceCenter = CGPointMake(face.bounds.origin.x + 0.5f * face.bounds.size.width,
                                    face.bounds.origin.y + 0.5f * face.bounds.size.height);
    }
    
    CGSize imgSize = self.extent.size;
    CGPoint faceCenter = CGPointMake(-0.5f + absFaceCenter.x / imgSize.width,
                                     -0.5f + absFaceCenter.y / imgSize.height);
    
    return faceCenter;
}


@end
