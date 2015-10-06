//
//  PLIDataAsImage.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/11/13.
//
//

#import "PLIDataAsImage.h"
#import "ApiError.h"

@implementation PLIDataAsImage

- (PipelineResult *)process:(id)input
{
    if (![input isKindOfClass:[NSData class]]) {
        return [[PipelineResult alloc] initWithError:[ApiError errorWithDescr:@"PipelineItem error"]];
    }
    
    UIImage *img = [UIImage imageWithData:input];
    
    if (!img) {
        return [[PipelineResult alloc] initWithError:[ApiError errorWithDescr:@"Bad image data"]];
    }
    
    return [[PipelineResult alloc] initWithResult:img];
}

@end
