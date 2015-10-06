//
//  CustomButton.h
//  TRN
//
//  Created by stolyarov on 04/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIControl

- (void)setUiForEnabled:(BOOL)enabled;
- (void)setSelected:(BOOL)selected;

@property(strong, nonatomic) IBOutlet UILabel *uiTitle;

@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL disabled;

@property (strong, nonatomic) IBInspectable UIColor *borderColor;
@property (assign, nonatomic) IBInspectable CGFloat borderWidth;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;

@property (strong, nonatomic) IBInspectable UIColor *highlightedColor;

@property (strong, nonatomic) IBInspectable UIColor *selectedTitleColor;
@property (strong, nonatomic) IBInspectable UIColor *selectedColor;

@property (strong, nonatomic) IBInspectable UIColor *disableTitleColor;
@property (strong, nonatomic) IBInspectable UIColor *disableColor;
@end
