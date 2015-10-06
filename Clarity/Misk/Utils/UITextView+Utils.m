//
//  UITextView+Utils.m
//  StaffApp
//
//  Created by stolyarov on 07/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "UITextView+Utils.h"

@implementation UITextView (Utils)

- (CGFloat) heightForAttributedString:(NSAttributedString *)attrString
                             forWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] initWithFrame:self.frame];
    textView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding;
    textView.attributedText = attrString;
    textView.textContainerInset = self.textContainerInset;
    textView.scrollEnabled = self.scrollEnabled;
    CGFloat height = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
    return ceilf(height);
}

@end
