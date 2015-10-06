//
//  PLIBlock.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/16/14.
//
//

#import "PipelineItem.h"
#import "ApiCanceler.h"

typedef PipelineResult *(^PPLProcessBlock)(id input);
typedef void (^PPLBlockOnComplete)(PipelineResult *result);
typedef void (^PPLProcessAsyncBlock)(id input, PipelineContext *ctx, PPLBlockOnComplete onComplete);

@interface PLIBlock : PipelineItem

- (instancetype)initWithBlock:(PPLProcessBlock)block;
- (instancetype)initWithAsyncBlock:(PPLProcessAsyncBlock)asyncBlock;

@end
