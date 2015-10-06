//
//  PLICropAndBlur.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/16/13.
//
//

#import "PipelineItem.h"

@interface PLICropAndBlur : PipelineItem

- (instancetype)initWithAvatarSize:(CGFloat)avatarSize
                          avatarId:(NSString *)avatarId
                        updateTime:(NSDate *)updateTime
                       applyCircle:(BOOL)applyCircle;

- (instancetype)initWithSquareSize:(CGFloat)squareSize applyCircle:(BOOL)applyCircle;

- (instancetype)initWithDstSize:(CGSize)size;
- (instancetype)initWithDstSize:(CGSize)size andBlur:(CGFloat)blurRadius;

+ (UIImage *)processAvatar:(CIImage *)avatar
           withOrientation:(UIImageOrientation)orientation
                   dstSize:(CGSize)dstSize
                  avatarId:(NSString *)avatarId
                updateTime:(NSDate *)updateTime;

@end
