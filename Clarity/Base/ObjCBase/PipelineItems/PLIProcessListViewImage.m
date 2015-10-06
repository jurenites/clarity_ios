//
//  PLIProcessListViewImage.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/7/14.
//
//

#import "PLIProcessListViewImage.h"
#import "CIContext+Shared.h"
#import "CIImage+AspectFill.h"

@interface PLIProcessListViewImage ()
{
    CGFloat _width;
}
@end

@implementation PLIProcessListViewImage

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super init];
    if (!self)
        return nil;
    
    _width = width;
    
    return self;
}

- (PipelineResult *)process:(id)input
{
    CIImage *src = [CIImage imageWithData:input];

    if (!src) {
        return [[PipelineResult alloc] initWithErrorDescr:@"PLIProcessListViewImage: bad image"];
    }
    
    return [[PipelineResult alloc] initWithResult:[src aspectFillForListViewWithWidth:_width]];
}

@end
