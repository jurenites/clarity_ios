//
//  ScrollViewForFields.h
//  TRN
//
//  Created by Alexey Klyotzin on 11/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollViewForFields : UIScrollView

- (void)myScrollRectToVisible:(CGRect)rect animated:(BOOL)animated;

@end
