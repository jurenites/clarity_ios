//
//  PipelineItem.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import <Foundation/Foundation.h>
#import "InternalError.h"

typedef void(^PPLOnSuccess)(id result);
typedef void(^PPLOnError)(NSError *error);
typedef void(^PPLCallOnPPLThread)(void(^)());
typedef void(^PPLRestartReq)(NSError *error);

//------------------------------------
@interface PipelineContext : NSObject

- (PipelineContext *)initWithOnSuccess:(PPLOnSuccess)onSuccess
                               onError:(PPLOnError)onError
                       callOnPPLThread:(PPLCallOnPPLThread)callOnPPLThread
                        restartRequest:(PPLRestartReq)restartRequest;

@property (readonly, nonatomic) PPLOnSuccess onSuccess;
@property (readonly, nonatomic) PPLOnError onError;
@property (readonly, nonatomic) PPLCallOnPPLThread callOnPPLThread;
@property (readonly, nonatomic) PPLRestartReq restartRequest;

@property (assign, nonatomic) NSInteger httpCode;
@property (assign, nonatomic) NSInteger requestId;

@end

//------------------------------------
@interface PipelineResult : NSObject

-(instancetype)initWithResult:(id)result;
-(instancetype)initWithError:(NSError*)error;
-(instancetype)initWithErrorDescr:(NSString*)descr;

@property (strong, readonly) id result;
@property (strong, readonly) NSError *error;

@end

//------------------------------------
@interface PipelineItem : NSObject

-(void)call:(id)input
    pipelineTail:(NSArray*)tail
    ctx:(PipelineContext*)ctx;

-(void)callNextItem:(id)output
    pipelineTail:(NSArray*)tail
    ctx:(PipelineContext*)ctx;

-(PipelineResult*)process:(id)input;

@end
