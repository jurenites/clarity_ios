//
//  PLIExtractRequestID.m
//  TRN
//
//  Created by Oleg Kasimov on 8/18/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "PLIExtractRequestID.h"

@interface PLIExtractRequestID ()
{
    PPLExtractRequestID _block;
}

@end

@implementation PLIExtractRequestID

- (instancetype)initWithBlock:(PPLExtractRequestID)block
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _block = [block copy];
    
    return self;
}

- (void)call:(id)input pipelineTail:(NSArray *)tail ctx:(PipelineContext *)ctx
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _block(ctx.requestId);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self callNextItem:input pipelineTail:tail ctx:ctx];
    });
}

@end
