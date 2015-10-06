//
//  NSThread+Utils.h
//  Brabble-iOSClient
//
//  Created by Alexey on 2/14/14.
//
//

#import <Foundation/Foundation.h>

@interface NSThread (Utils)

- (void)performBlock:(void(^)())block;
- (void)performAsyncBlock:(void(^)())block;

@end
