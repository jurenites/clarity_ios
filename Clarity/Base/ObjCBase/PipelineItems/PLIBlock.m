//
//  PLIBlock.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/16/14.
//
//

#import "PLIBlock.h"
#import "ApiCancelerFlag.h"

@interface PLIBlock ()
{
    PPLProcessBlock _block;
    PPLProcessAsyncBlock _asyncBlock;
}
@end

@implementation PLIBlock

- (instancetype)initWithBlock:(PPLProcessBlock)block
{
    self = [super init];
    if (!self)
        return nil;
    
    _block = [block copy];
    
    return self;
}

- (instancetype)initWithAsyncBlock:(PPLProcessAsyncBlock)asyncBlock
{
    self = [super init];
    if (!self)
        return nil;
    
    _asyncBlock = [asyncBlock copy];
    
    return self;
}

- (void)call:(id)input pipelineTail:(NSArray *)tail ctx:(PipelineContext *)ctx
{
    if (_asyncBlock) {
        _asyncBlock(input, ctx, ^(PipelineResult *result) {
            if (result.error) {
                ctx.onError(result.error);
                return;
            }
            [self callNextItem:result.result pipelineTail:tail ctx:ctx];
        });
    } else {
        [super call:input pipelineTail:tail ctx:ctx];
    }
}

- (PipelineResult *)process:(id)input
{
    return _block(input);
}

@end
