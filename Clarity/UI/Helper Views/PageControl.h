//
//  PageControl.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 4/4/14.
//
//

#import <UIKit/UIKit.h>

@interface PageControl : UIView

- (void)setup;

@property (assign, nonatomic) IBInspectable NSInteger pagesCount;
@property (assign, nonatomic) IBInspectable CGFloat diameter;
@property (assign, nonatomic) IBInspectable CGFloat interval;
@property (strong, nonatomic) IBInspectable UIColor *color;
@property (strong, nonatomic) IBInspectable UIColor *selectedColor;

@property (assign, nonatomic) IBInspectable CGFloat borderWidth;
@property (strong, nonatomic) IBInspectable UIColor *borderColor;

@property (assign, nonatomic) IBInspectable NSUInteger selectedPage;

@end
