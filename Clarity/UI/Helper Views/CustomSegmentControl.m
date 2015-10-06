//
//  CustomSegmentControl.m
//  TRN
//
//  Created by stolyarov on 08/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "CustomSegmentControl.h"
#import "Separator.h"
#import "CustomButton.h"

@interface CustomSegmentControl ()
{
    NSMutableIndexSet *_selectedIndexes;
    NSMutableIndexSet *_disabledIndexes;
    UIColor *_defaultColor;
}
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *uiViews;
@end

@implementation CustomSegmentControl

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!self.uiViews.count) {
        return;
    }
    _selectedIndexes = [NSMutableIndexSet new];
    _disabledIndexes = [NSMutableIndexSet new];
    
    self.uiViews = [self.uiViews sortedArrayUsingComparator:^NSComparisonResult(id btn1, id btn2) {
        if ([btn1 frame].origin.x < [btn2 frame].origin.x) return NSOrderedAscending;
        else if ([btn1 frame].origin.x > [btn2 frame].origin.x) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
    
    for (NSInteger i = 0; i < self.uiViews.count;i++) {
        UIView *btn = (UIView *)self.uiViews[i];
        btn.tag = i;
    }
    
    if (!_selectedColor) {
        _selectedColor = self.backgroundColor;
    }
    if (!_highlightedColor) {
        _highlightedColor = [_selectedColor colorWithAlphaComponent:0.5];
    }
    _defaultColor = [self.uiViews.firstObject backgroundColor];
}

- (void)setSelectedSegmentsAtIndexes:(NSIndexSet *)indexSet
{
    [_selectedIndexes removeAllIndexes];
    
    if (indexSet.count) {
        [_selectedIndexes addIndexes:indexSet];
    }
    
    [self.uiViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![_disabledIndexes containsIndex:[obj tag]]) {
            [obj setSelected:[_selectedIndexes containsIndex:[obj tag]]];
        }
    }];
}

- (NSIndexSet *)selectedIndexes
{
    return _selectedIndexes;
}

- (void)setDisabledSegmentsAtIndexes:(NSIndexSet *)indexSet
{
    [_disabledIndexes removeAllIndexes];
    
    if (indexSet.count) {
        [_disabledIndexes addIndexes:indexSet];
    }
    
    [self.uiViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([_disabledIndexes containsIndex:[obj tag]]) {
            [obj setEnabled:NO];
            if ([_selectedIndexes containsIndex:[obj tag]]) {
                [_selectedIndexes removeIndex:[obj tag]];
            }
        } else {
            [obj setEnabled:YES];
        }
    }];
    
    [self setSelectedSegmentsAtIndexes:[_selectedIndexes copy]];
}

- (NSIndexSet *)disabledIndexes
{
    return _disabledIndexes;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (IBAction)actChoose:(id)sender
{
    if (!self.isMultiSelect) {
        if (_selectedIndexes.firstIndex != NSNotFound) {
            if ([sender tag] != _selectedIndexes.firstIndex) {
                [self.uiViews makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
                [_selectedIndexes removeAllIndexes];
                
                [_selectedIndexes addIndex:[sender tag]];
                [sender setSelected:YES];
            }
        } else {
            [_selectedIndexes addIndex:[sender tag]];
            [sender setSelected:YES];
        }
    } else {
        if ([sender isSelected]) {
            [_selectedIndexes removeIndex:[sender tag]];
        } else {
            [_selectedIndexes addIndex:[sender tag]];
        }
        [sender setSelected:![sender isSelected]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (!_disabledIndexes.count) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    for (CustomButton *s in self.uiViews) {
        if (s.enabled == NO) {
            if (CGRectContainsPoint(s.frame, location) ) {
                if ([self.delegate respondsToSelector:@selector(segmentControl:didTapOnDisabledSegmentAtIndex:)]) {
                    [self.delegate segmentControl:self didTapOnDisabledSegmentAtIndex:s.tag];
                }
            }
        }
    }
}

@end
