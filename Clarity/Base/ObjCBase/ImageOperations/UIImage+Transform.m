//
//  UIImage+Transform.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/5/14.
//
//

#import "UIImage+Transform.h"

@implementation UIImage (Transform)

+ (CGSize)convertSize:(CGSize)size forOrientation:(UIImageOrientation)orientation
{
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            return CGSizeMake(size.height, size.width);
            
        default:
            break;
    }
    
    return size;
}

+ (CGFloat)angleForOrientation:(UIImageOrientation)orientation
{
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationRightMirrored:
            return M_PI_2;
            
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
            return -M_PI_2;
            
        case UIImageOrientationDown:
        case UIImageOrientationUpMirrored:
            return M_PI;
            
        default:
            break;
    }
    
    return 0.0f;
}

static BOOL CGPointEqualToPoint2(CGPoint pt, CGPoint pt2)
{
    static CGFloat sigma = 0.001f;
    
    return fabsf(pt.x - pt2.x) < sigma && fabsf(pt.y - pt2.y) < sigma;
}

+ (UIImageOrientation)orientationForTransform:(CGAffineTransform)transform
{
    transform.tx = 0;
    transform.ty = 0;
    
    CGPoint transformed = CGPointApplyAffineTransform(CGPointMake(0, 1), transform);
    
    if (CGPointEqualToPoint2(transformed, CGPointMake(1, 0))) {
        return UIImageOrientationRight;
    } else if (CGPointEqualToPoint2(transformed, CGPointMake(0, -1))) {
        return UIImageOrientationDown;
    } else if (CGPointEqualToPoint2(transformed, CGPointMake(-1, 0))) {
        return UIImageOrientationLeft;
    }
    
    return UIImageOrientationUp;
}

+ (UIImageOrientation)orientationForTransformYDown:(CGAffineTransform)transform
{
    transform.tx = 0;
    transform.ty = 0;
    
    CGPoint transformed = CGPointApplyAffineTransform(CGPointMake(1, 0), transform);
    
    if (CGPointEqualToPoint2(transformed, CGPointMake(0, 1))) {
        return UIImageOrientationRight;
    } else if (CGPointEqualToPoint2(transformed, CGPointMake(-1, 0))) {
        return UIImageOrientationDown;
    } else if (CGPointEqualToPoint2(transformed, CGPointMake(0, -1))) {
        return UIImageOrientationLeft;
    }
    
    return UIImageOrientationUp;
}

+ (UIImageOrientation)orientationForTransform:(CGAffineTransform)transform isMirrored:(BOOL)mirrored
{
    UIImageOrientation orientation = [self orientationForTransform:transform];
    
    if (!mirrored) {
        return orientation;
    }
    
    switch (orientation) {
        case UIImageOrientationUp:
            return UIImageOrientationDownMirrored;
            
        case UIImageOrientationDown:
            return UIImageOrientationUpMirrored;
            
        case UIImageOrientationLeft:
            return UIImageOrientationRightMirrored;
            
        case UIImageOrientationRight:
            return UIImageOrientationLeftMirrored;
            
        default:
            break;
    }
    
    return orientation;
}

+ (CGAffineTransform)transform:(CGAffineTransform)transform withOrientation:(UIImageOrientation)orientation
{
    CGFloat angle = 0;
 
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            angle = M_PI_2;
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            angle = -M_PI_2;
            break;
            
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            angle = M_PI;
            break;
            
        default:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformScale(transform, 1, -1);
            break;
            
        default:
            break;
    }
    
    return CGAffineTransformRotate(transform, angle);
}

+ (BOOL)isOrientationMirrored:(UIImageOrientation)orientation
{
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            return YES;
            
        default:
            break;
    }
    return NO;
}

@end
