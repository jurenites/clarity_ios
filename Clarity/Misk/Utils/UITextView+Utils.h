//
//  UITextView+Utils.h
//  StaffApp
//
//  Created by stolyarov on 07/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Utils)
- (CGFloat) heightForAttributedString:(NSAttributedString *)attrString
                              forWidth:(CGFloat)width;
@end
