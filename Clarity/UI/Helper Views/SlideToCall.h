//
//  SlideView.h
//  TRN
//
//  Created by stolyarov on 26/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SlideToCallDelegate <NSObject>
- (void)makeCallOnComplete:(void(^)())onComplete;
@end

@interface SlideToCall : UIView
@property (assign, nonatomic) id <SlideToCallDelegate> delegate;

@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) CGFloat cornerRadius;

@property (strong, nonatomic) UIColor *highlightedColor;
@end
