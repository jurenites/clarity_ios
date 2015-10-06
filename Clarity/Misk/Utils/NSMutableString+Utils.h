//
//  NSMutableString+Utils.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/18/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Utils)

- (void)appendChar:(unichar)character;
- (void)prependChar:(unichar)character;

@end
