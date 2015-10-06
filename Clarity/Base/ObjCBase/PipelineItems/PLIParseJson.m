//
//  PLIParseJson.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/14/14.
//
//

#import "PLIParseJson.h"

@implementation PLIParseJson

-(PipelineResult*)process:(id)input
{
    if (![input isKindOfClass:[NSData class]]) {
        return [[PipelineResult alloc] initWithErrorDescr: @"PLIParseJSON error"];
    }
    
    id output = [NSJSONSerialization JSONObjectWithData:input options:0 error:nil];
    
    if (!output) {
        return [[PipelineResult alloc] initWithErrorDescr: @"JSON parse error"];
    }
    
    return [[PipelineResult alloc] initWithResult:output];
}

@end
