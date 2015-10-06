//
//  UIImage+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey on 2/28/14.
//
//

#import "UIImage+Utils.h"
#import "CIContext+Shared.h"
#import "DeviceHardware.h"

@implementation UIImage (Utils)

+ (void)warmUpImageNamed:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        return;
    }
    
    const CGSize buffSize = CGSizeMake(64, 64);
    
    UIGraphicsBeginImageContext(buffSize);
    
    [image drawInRect:CGRectMake(0, 0, buffSize.width, buffSize.height)];
    
    UIGraphicsEndImageContext();
}

- (UIImage *)removeAlpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, YES, self.scale);
    
    [self drawAtPoint:CGPointZero];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)makeDarker
{
    CIImage *img = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"];
    
    [filter setValue:img forKeyPath:@"inputImage"];
    [filter setValue:[CIVector vectorWithX:0.4 Y:0 Z:0 W:0] forKeyPath:@"inputRVector"];
    [filter setValue:[CIVector vectorWithX:0 Y:0.4 Z:0 W:0] forKeyPath:@"inputGVector"];
    [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0.4 W:0] forKeyPath:@"inputBVector"];
    [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKeyPath:@"inputAVector"];
    
    CIContext *ctx = [CIContext shared];
    
    CGImageRef cgImg = [ctx createCGImage:[filter valueForKey:kCIOutputImageKey]
                                 fromRect:img.extent];
    
    
    UIImage *result = [UIImage imageWithCGImage:cgImg
                                          scale:self.scale
                                    orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return result;
    
}

- (UIImage *)changeColor:(UIColor *)color
{
    if ([DeviceHardware lowerThaniOS7]) {
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGImageRef origImg = CGImageCreateCopyWithColorSpace(self.CGImage, rgb);
        CGColorSpaceRelease(rgb);
        CIImage *img = [CIImage imageWithCGImage:origImg];
        CGImageRelease(origImg);
        
        CGFloat r = 0, g = 0, b = 0, a = 0;
        
        [color getRed:&r green:&g blue:&b alpha:&a];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"];
        
        [filter setValue:img forKeyPath:@"inputImage"];
        [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKeyPath:@"inputRVector"];
        [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKeyPath:@"inputGVector"];
        [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKeyPath:@"inputBVector"];
        [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKeyPath:@"inputAVector"];
        [filter setValue:[CIVector vectorWithX:powf(r, 2.2f) Y:powf(g, 2.2f) Z:powf(b, 2.2f) W:0] forKeyPath:@"inputBiasVector"];
        
        CIContext *ctx = [CIContext shared];
        
        CGImageRef cgImg = [ctx createCGImage:[filter valueForKey:kCIOutputImageKey]
                                     fromRect:img.extent];
        
        
        UIImage *result = [UIImage imageWithCGImage:cgImg
                                              scale:self.scale
                                        orientation:UIImageOrientationUp];
        CGImageRelease(cgImg);
        
        return result;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CALayer *layer = [[CALayer alloc] init];
    
    layer.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    layer.shouldRasterize = YES;
    layer.rasterizationScale = self.scale;
    layer.backgroundColor = color.CGColor;
    
    CALayer *mask = [[CALayer alloc] init];
    
    mask.frame = layer.frame;
    mask.shouldRasterize = YES;
    mask.rasterizationScale = self.scale;
    mask.contents = (__bridge id)self.CGImage;
    
    layer.mask = mask;
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)applyCircleMask
{
    CALayer *layer = [CALayer new];
    
    layer.contents = (__bridge id)self.CGImage;
    layer.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    layer.shouldRasterize = YES;
    layer.rasterizationScale = self.scale;
    layer.masksToBounds = YES;
    layer.cornerRadius = self.size.width * 0.5f;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)resizeForWidth:(CGFloat)width
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, self.size.height), NO, self.scale);
    
    [self drawInRect:CGRectMake(0, 0, width, self.size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage *)cropBackgroungPieceFrom:(CGFloat)y withHeight:(CGFloat)height
{
    UIImage *bg = [UIImage imageNamed:@"background"];
    CGSize size = CGSizeMake(bg.size.width, height ? height : (bg.size.height - y));
    
    UIGraphicsBeginImageContextWithOptions(size, NO, bg.scale);
    
    [bg drawInRect:CGRectMake(0, -y, size.width, bg.size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
