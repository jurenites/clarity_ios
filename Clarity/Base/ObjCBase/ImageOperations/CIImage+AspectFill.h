//
//  CIImage+Crop.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/5/14.
//
//

#import <CoreImage/CoreImage.h>

static const CGFloat BBCoverBlurRadius = 6;

@interface CIImage (AspectFill)

- (CGAffineTransform)aspectFillTransformWithSize:(CGSize)size
                                     orientation:(UIImageOrientation)orientation;

- (CGAffineTransform)headAspectFillTransformToSize:(CGSize)size
                                 normalizedHeadPos:(CGPoint)normalizedHeadPos
                                       orientation:(UIImageOrientation)orientation;

- (UIImage *)aspectFillWithSize:(CGSize)size;
- (UIImage *)aspectFillWithSize:(CGSize)size orientation:(UIImageOrientation)orientation;

- (UIImage *)headAspectFillWithSize:(CGSize)size
                  normalizedHeadPos:(CGPoint)normalizedHeadPos
                        orientation:(UIImageOrientation)orientation;

- (UIImage *)aspectFillWithSize:(CGSize)size
                    orientation:(UIImageOrientation)orientation
                     blurRadius:(CGFloat)blurRadius;

- (UIImage *)aspectFillForListViewWithWidth:(CGFloat)width;

- (UIImage *)processCoverPhotoWithWidth:(CGFloat)width
                            orientation:(UIImageOrientation)orientation
                             blurRadius:(CGFloat)blurRadius
                               gradient:(BOOL)gradient;

- (UIImage *)aspectFillWithSize:(CGSize)size
                    orientation:(UIImageOrientation)orientation
                     addOverlay:(BOOL)addOverlay;

- (CGPoint)getHeadPosWithOrientation:(UIImageOrientation)orientation;

@end
