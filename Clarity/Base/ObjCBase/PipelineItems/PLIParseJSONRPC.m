//
//  PLIParseJSONRPC.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/21/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "PLIParseJSONRPC.h"

#import "NSError+IO.h"
#import "NSObject+Api.h"
#import "ApiRouter_Auth.h"
#import "ApiError.h"
#import "ApiRouter.h"
#import "HttpError.h"

@implementation PLIParseJSONRPC
- (void)call:(id)input
pipelineTail:(NSArray *)tail
         ctx:(PipelineContext *)ctx
{
    if (![input isKindOfClass:[NSData class]]) {
        ctx.onError([InternalError errorWithDescr:@"PLIParseJSON error"]);
        return;
    }
    
    NSData *inputData = input;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:inputData options:0 error:nil];
    
    if (response == nil) {
        ctx.onError([InternalError errorWithDescr:@"An error occurred while connecting to the server. Please try again."]);
        return;
    } else if (![response isKindOfClass:[NSDictionary class]]) {
        ctx.onError([InternalError errorWithDescr:@"Server error"]);
        return;
    }
    
    if (response[@"success"] && ToBool(response[@"success"])) {
        if (response[@"result"] && ![response[@"result"] isKindOfClass:[NSNull class]]) {
            ctx.requestId = ToInt(response[@"request_id"]);
            [self callNextItem:response[@"result"] pipelineTail:tail ctx:ctx];
        } else {
            [self callNextItem:response pipelineTail:tail ctx:ctx];
        }
    } else if (response[@"code"]) {
        NSInteger code = ToInt(response[@"code"]);
        
        if (code == ApiErrorBadSessionToken || code == ApiErrorSessionTokenExpired) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ApiRouter shared] invalidateLogin];
            });
        }
        
        NSString *descr = nil;
        if (response[@"message"]) {
            descr = response[@"message"];
        }
        ctx.onError([ApiError errorWithCode:code descr:descr]);
    } else {
        ctx.onError([InternalError errorWithDescr:@"Unknown error"]);
    }
    
}

@end
