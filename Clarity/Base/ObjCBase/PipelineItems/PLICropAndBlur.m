//
//  PLICropAndBlur.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/16/13.
//
//

#import "PLICropAndBlur.h"
#import <CoreImage/CoreImage.h>
#import "CIContext+Shared.h"
#import "CIImage+AspectFill.h"
#import "UIImage+Utils.h"
#import "AvatarInfo.h"
#import "ApiRouter.h"

@interface PLICropAndBlur ()
{
    CGSize _dstSize;
    CGFloat _blurRadius;
    BOOL _applyBlur;
    BOOL _applyCircle;
    CGFloat _alphaOverlay;
    
    NSString *_avatarId;
    NSDate *_updateTime;
}
@end

@implementation PLICropAndBlur

- (instancetype)initWithAvatarSize:(CGFloat)avatarSize
                          avatarId:(NSString *)avatarId
                        updateTime:(NSDate *)updateTime
                       applyCircle:(BOOL)applyCircle
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _dstSize = CGSizeMake(avatarSize, avatarSize);
    _applyCircle = applyCircle;
    _avatarId = avatarId;
    _updateTime = updateTime;
    
    return self;
}

- (instancetype)initWithSquareSize:(CGFloat)squareSize applyCircle:(BOOL)applyCircle
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _dstSize = CGSizeMake(squareSize, squareSize);
    _applyCircle = applyCircle;
    
    return self;
}

- (instancetype)initWithDstSize:(CGSize)size
{
    self = [super init];
    if (!self)
        return nil;
    
    _dstSize = size;
    
    return self;
}

- (instancetype)initWithDstSize:(CGSize)size andBlur:(CGFloat)blurRadius
{
    self = [super init];
    if (!self)
        return nil;
    
    _dstSize = size;
    _blurRadius = blurRadius;
    _applyBlur = TRUE;
    
    return self;
}

+ (UIImage *)processAvatar:(CIImage *)avatar
           withOrientation:(UIImageOrientation)orientation
                   dstSize:(CGSize)dstSize
                  avatarId:(NSString *)avatarId
                updateTime:(NSDate *)updateTime
{
    __block AvatarInfo *ai = nil;

    [[ApiRouter shared].db exec:^(Database *db) {
        ai = [AvatarInfo avatarInfoWithId:avatarId fromDb:db];
        
        if (ai && updateTime && (!ai.updateTime || [updateTime timeIntervalSinceDate:ai.updateTime] > 10)) {
            [AvatarInfo dbDeleteById:avatarId db:db];
            ai = nil;
        }
    }];
    
    if (!ai) {
        CGPoint head = [avatar getHeadPosWithOrientation:orientation];
        
        ai = [AvatarInfo new];
        ai.avatarId = avatarId;
        ai.headXPos = head.x;
        ai.headYPos = head.y;
        ai.updateTime = updateTime;
        
        [[ApiRouter shared].db exec:^(Database *db) {
            if (![AvatarInfo avatarInfoWithId:avatarId fromDb:db]) {
                [ai dbInsert:db];
            }
        }];
    }

    return [avatar headAspectFillWithSize:dstSize normalizedHeadPos:CGPointMake(ai.headXPos, ai.headYPos)
                              orientation:orientation];
}

- (PipelineResult *)process:(id)input
{
    UIImage *img = [UIImage imageWithData:input];
    
    if (!img) {
        return [[PipelineResult alloc] initWithErrorDescr:@"PipelineItem error"];
    }
    
    CIImage *src = [CIImage imageWithCGImage:img.CGImage];
    UIImage *result = nil;
    
    if (_avatarId.length) {
        result = [[self class] processAvatar:src withOrientation:img.imageOrientation dstSize:_dstSize
                                    avatarId:_avatarId updateTime:_updateTime];
    } else if (_applyBlur) {
        result = [src aspectFillWithSize:_dstSize orientation:img.imageOrientation blurRadius:_blurRadius];
    } else {
        result = [src aspectFillWithSize:_dstSize orientation:img.imageOrientation];
    }
    
    if (_applyCircle) {
        result = [result applyCircleMask];
    }
    
    return [[PipelineResult alloc] initWithResult:result];
}




@end
