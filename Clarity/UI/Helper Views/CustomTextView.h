//
//  CustomTextView.h
//  TRN
//
//  Created by stolyarov on 30/04/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextView : UITextView

@property (strong, nonatomic) IBInspectable UIColor *placeholderColor;
@property (strong, nonatomic) IBInspectable NSString *placeholder;
@property (assign, nonatomic) IBInspectable NSInteger maxSymbolsCount;

@end
