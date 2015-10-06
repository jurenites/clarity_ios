//
//  NetReachability.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/11/13.
//
//

#import "NetReachability.h"

#import <SystemConfiguration/SystemConfiguration.h>

@interface NetReachability ()
{
    SCNetworkReachabilityRef m_reachability_ref;
    id<NetReachabilityDelegate> __weak m_delegate;
}

-(void)reachabilityChanged;

@property (readonly, nonatomic) BOOL isReachableViaWWAN;
@property (readonly, nonatomic) BOOL isReachableViaWiFi;

@end

static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) 
{
    NetReachability *iom = ((__bridge NetReachability*)info);

    [iom reachabilityChanged];
}

@implementation NetReachability

-(id)initWithHostname:(NSString*)hostname
    runLoop:(NSRunLoop*)runLoop
    delegate:(id<NetReachabilityDelegate>)delegate;
{
    self = [super init];
    if (!self)
        return nil;
    
    m_delegate = delegate;
    
    SCNetworkReachabilityContext context = {0, NULL, NULL, NULL, NULL};
    
    m_reachability_ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    
    if (!m_reachability_ref)
        return nil;
    
    context.info = (__bridge void*)self;
    SCNetworkReachabilitySetCallback(m_reachability_ref, TMReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(m_reachability_ref, [runLoop getCFRunLoop], kCFRunLoopDefaultMode);
    
    return self;
}

-(void)dealloc
{
    SCNetworkReachabilityUnscheduleFromRunLoop(m_reachability_ref, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    SCNetworkReachabilitySetCallback(m_reachability_ref, NULL, NULL);
    CFRelease(m_reachability_ref);
}

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
    return connectionUP;
}

-(BOOL)isReachable
{
    SCNetworkReachabilityFlags flags;  
    
    if(!SCNetworkReachabilityGetFlags(m_reachability_ref, &flags))
        return NO;
    
    return [self isReachableWithFlags:flags];
}

-(BOOL)isReachableViaWWAN
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(m_reachability_ref, &flags)) {
        // Check we're REACHABLE
        if(flags & kSCNetworkReachabilityFlagsReachable) {
            // Now, check we're on WWAN
            if(flags & kSCNetworkReachabilityFlagsIsWWAN) {
                return YES;
            }
        }
    }
    
    return FALSE;
}

-(BOOL)isReachableViaWiFi
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(m_reachability_ref, &flags)) {
        // Check we're reachable
        if((flags & kSCNetworkReachabilityFlagsReachable)) {
            // Check we're NOT on WWAN
            if(!(flags & kSCNetworkReachabilityFlagsIsWWAN)) {
                return YES;
            }
        }
    }
    
    return NO;
}

-(IONetReachability)status
{
    if (self.isReachable) {
        if (self.isReachableViaWiFi)
            return IONetReachabilityWifi;
        else if (self.isReachableViaWWAN)
            return IONetReachabilityCellular;
    }
    
    return IONetReachabilityNone;
}

-(void)reachabilityChanged
{
    if ([m_delegate respondsToSelector:@selector(netReachabilityChanged:status:)]) {
        [m_delegate netReachabilityChanged:self status:self.status];
    }
}

+(BOOL)statusToInOnline:(IONetReachability)status
{
    return status == IONetReachabilityCellular || status == IONetReachabilityWifi;
}

@end
