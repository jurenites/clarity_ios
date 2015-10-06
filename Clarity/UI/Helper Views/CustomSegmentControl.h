//
//  CustomSegmentControl.h
//  TRN
//
//  Created by stolyarov on 08/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomSegmentControl;
@protocol CustomSegmentControlDelegate <NSObject>

@optional
- (void)segmentControl:(CustomSegmentControl *)segmentControl didTapOnDisabledSegmentAtIndex:(NSInteger)index;

@end

@interface CustomSegmentControl : UIControl

- (void)setSelectedSegmentsAtIndexes:(NSIndexSet *)indexSet;
- (NSIndexSet *)selectedIndexes;

- (void)setDisabledSegmentsAtIndexes:(NSIndexSet *)indexSet;
- (NSIndexSet *)disabledIndexes;

@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) BOOL isMultiSelect;

@property (strong, nonatomic) UIColor *highlightedColor;
@property (strong, nonatomic) UIColor *selectedColor;

@property (weak, nonatomic) id<CustomSegmentControlDelegate> delegate;

@end
