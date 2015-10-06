//
//  PLIExtractRequestID.h
//  TRN
//
//  Created by Oleg Kasimov on 8/18/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "PipelineItem.h"

typedef void(^PPLExtractRequestID)(NSInteger requestId);

@interface PLIExtractRequestID : PipelineItem

- (instancetype)initWithBlock:(PPLExtractRequestID)block;

@end
