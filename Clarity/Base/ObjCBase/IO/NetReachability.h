//
//  NetReachability.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/11/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    IONetReachabilityNone,
    IONetReachabilityWifi,
    IONetReachabilityCellular
    
} IONetReachability;

@class NetReachability;

@protocol NetReachabilityDelegate <NSObject>

-(void)netReachabilityChanged:(NetReachability*)nr status:(IONetReachability)status;

@end

@interface NetReachability : NSObject

+(BOOL)statusToInOnline:(IONetReachability)status;

-(id)initWithHostname:(NSString*)hostname
    runLoop:(NSRunLoop*)runLoop
    delegate:(id<NetReachabilityDelegate>)delegate;

@property (readonly, nonatomic) BOOL isReachable;
@property (readonly, nonatomic) IONetReachability status;

@end
