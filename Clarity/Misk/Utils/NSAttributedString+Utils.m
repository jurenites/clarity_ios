//
//  NSAttributedString+Utils.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 8/5/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "NSAttributedString+Utils.h"

@implementation NSAttributedString (Utils)

- (CGFloat)heightForWidth:(CGFloat)width
{
    CGRect rc = [self boundingRectWithSize:CGSizeMake(width, 8000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return ceil(rc.size.height);
}

@end
