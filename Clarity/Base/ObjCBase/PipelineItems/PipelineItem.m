//
//  PipelineItem.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import "PipelineItem.h"
#import "InternalError.h"

//----------------------------------
@implementation PipelineContext

-(PipelineContext*)initWithOnSuccess:(PPLOnSuccess)onSuccess
    onError:(PPLOnError)onError
    callOnPPLThread:(PPLCallOnPPLThread)callOnPPLThread
    restartRequest:(PPLRestartReq)restartRequest
{
    self = [super init];
    if (!self)
        return nil;
    
    _onSuccess = [onSuccess copy];
    _onError = [onError copy];
    _callOnPPLThread = [callOnPPLThread copy];
    _restartRequest = [restartRequest copy];
    
    return self;
}

@end

//-------------------------------------
@implementation PipelineResult

-(instancetype)initWithResult:(id)result
{
    self = [super init];
    if (!self)
        return nil;
    
    _result = result;
    
    return self;
}

-(instancetype)initWithError:(NSError *)error
{
    self = [super init];
    if (!self)
        return nil;
    
    _error = error;
    
    return self;
}


-(instancetype)initWithErrorDescr:(NSString*)descr
{
    return [self initWithError:[InternalError errorWithCode:0 descr:descr]];
}

@end

//----------------------------------
@implementation PipelineItem

- (void)call:(id)input
pipelineTail:(NSArray *)tail
         ctx:(PipelineContext *)ctx
{
    PipelineResult *res = [self process:input];

    if (res.error) {
        ctx.onError(res.error);
        return;
    }

    [self callNextItem:res.result pipelineTail:tail ctx:ctx];
}

- (void)callNextItem:(id)output
        pipelineTail:(NSArray *)tail
                 ctx:(PipelineContext *)ctx
{
    if (tail.count == 0) {
        ctx.onSuccess(output);
        return;
    }
    
    PipelineItem *next = tail.firstObject;
    
    [next call:output
  pipelineTail:[tail subarrayWithRange:NSMakeRange(1, tail.count - 1)]
           ctx:ctx];
}

- (PipelineResult *)process:(id)input;
{
    return [[PipelineResult alloc] initWithResult:input];
}

@end
