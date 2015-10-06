//
//  UIImage+Utils.h
//  Brabble-iOSClient
//
//  Created by Alexey on 2/28/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (void)warmUpImageNamed:(NSString *)imageName;

- (UIImage *)removeAlpha;

- (UIImage *)changeColor:(UIColor *)color;

- (UIImage *)applyCircleMask;

- (UIImage *)resizeForWidth:(CGFloat)width;

- (UIImage *)makeDarker;

+ (UIImage *)cropBackgroungPieceFrom:(CGFloat)y withHeight:(CGFloat)height;


@end
