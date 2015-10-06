//
//  DelegatesHolder.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@interface DelegatesHolder : NSObject

-(void)addDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;
-(void)removeAllDelegates;
-(NSSet*)getDelegates;

@end
