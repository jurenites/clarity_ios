//
//  NSMutableString+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/18/14.
//
//

#import "NSMutableString+Utils.h"

@implementation NSMutableString (Utils)

- (void)appendChar:(unichar)character
{
    [self appendString:[NSString stringWithCharacters:&character length:1]];
}

- (void)prependChar:(unichar)character
{
    [self insertString:[NSString stringWithCharacters:&character length:1]
               atIndex:0];
}

@end
