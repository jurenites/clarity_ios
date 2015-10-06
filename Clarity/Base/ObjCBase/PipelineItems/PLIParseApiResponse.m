//
//  PLIParseJSON.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import "PLIParseApiResponse.h"
#import "NSError+IO.h"
#import "NSObject+Api.h"
#import "ApiRouter_Auth.h"
#import "ApiError.h"
#import "ApiRouter.h"
#import "HttpError.h"

static const int ErrorMalformedSessionToken = 43;

@implementation PLIParseApiResponse

- (void)call:(id)input
pipelineTail:(NSArray *)tail
         ctx:(PipelineContext *)ctx
{
    if (![input isKindOfClass:[NSData class]]) {
        ctx.onError([InternalError errorWithDescr:@"PLIParseJSON error"]);
        return;
    }
    
    NSData *inputData = input;
    
    if (inputData.length == 0) {
        if (ctx.httpCode < 200 || ctx.httpCode >= 300) {
            ctx.onError([HttpError errorWithCode:ctx.httpCode]);
        } else {
            [self callNextItem:@[] pipelineTail:tail ctx:ctx];
        }
        return;
    }
    
    id output = [NSJSONSerialization JSONObjectWithData:inputData options:0 error:nil];
    
    if (!output) {
        ctx.onError([InternalError errorWithDescr:@"JSON parse error"]);
        return;
    } else if ([output isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = output;
        
        if (dict[@"errnum"]) {
            const int errnum = (int)ToInt(dict[@"errnum"]);
            
            if (errnum == ErrorMalformedSessionToken) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[ApiRouter shared] logout];
                });
                
                ctx.onError([ApiError errorWithCode:errnum descr:ToString(dict[@"errmsg"])]);
                return;
            }
            
            ctx.onError([ApiError errorWithCode:errnum descr:ToString(dict[@"errmsg"])]);
            return;
        } else if ((dict.count == 2 || [ToString(dict[@"type"]) isEqualToString:@"OAuthException"])
                   && dict[@"code"] && dict[@"message"]) {
            ctx.onError([ApiError errorWithCode:ToInt(dict[@"code"]) descr:ToString(dict[@"message"])]);
            return;
        }
    }
    
    if (ctx.httpCode < 200 || ctx.httpCode >= 300) {
        ctx.onError([HttpError errorWithCode:ctx.httpCode]);
        return;
    }

    [self callNextItem:output pipelineTail:tail ctx:ctx];
}


@end
