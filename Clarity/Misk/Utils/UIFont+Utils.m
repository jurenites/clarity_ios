//
//  UIFont+Utils.m
//  StaffApp
//
//  Created by stolyarov on 19/08/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "UIFont+Utils.h"

@implementation UIFont (Utils)
+ (UIFont *) fontFromString:(NSString *) fontInfo
{
    NSArray *info = [fontInfo componentsSeparatedByString:@";"];
    
    if(info.count != 2) {
        NSLog(@"Error : wrong font!");
        return nil;
    }
    
    NSString *fontName = info[0];
    CGFloat fontSize = [info[1] floatValue];
    
    return [UIFont fontWithName:fontName size:fontSize];
}
@end
