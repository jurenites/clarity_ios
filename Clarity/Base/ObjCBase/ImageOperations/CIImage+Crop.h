//
//  CIImage+Crop.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/6/14.
//
//

#import <CoreImage/CoreImage.h>

@interface CIImage (Crop)

- (UIImage *)cropWithNormalizedSrcRect:(CGRect)srcRect
                               dstWidth:(CGFloat)dstWidth
                           orientation:(UIImageOrientation)orientation;

@end
