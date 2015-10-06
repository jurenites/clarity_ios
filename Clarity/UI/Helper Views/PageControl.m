//
//  PageControl.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 4/4/14.
//
//

#import "PageControl.h"
#import "UIView+Utils.h"

@interface PageControl ()
{
    UIView *_container;
    NSArray *_dots;
    
    CGRect _xibFrame;
}
@property (nonatomic, strong)IBOutlet NSLayoutConstraint *uiWidth;
@end

@implementation PageControl

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [self setup];
    _xibFrame = self.frame;
}

- (void)setup
{
    if (_container) {
        [_container removeFromSuperview];
    }
    _container = [[UIView alloc] initWithFrame:
                  CGRectMake(0, 0,
                    self.pagesCount * (self.diameter + self.interval) - self.interval, self.diameter)];
    
    [self addSubview:_container];
    
    self.uiWidth.constant = _container.width;
    
    NSMutableArray *dots = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.pagesCount; i++) {
        UIView *dot = [[UIView alloc] initWithFrame:
                       CGRectMake((self.diameter + self.interval) * i, 0, self.diameter, self.diameter)];
        
        dot.backgroundColor = (i == (NSInteger)self.selectedPage) ?  self.selectedColor : self.color;
        dot.layer.cornerRadius = 0.5f * self.diameter;
        
        dot.layer.borderColor = [self.borderColor CGColor];
        dot.layer.borderWidth = (i == (NSInteger)self.selectedPage) ?  0.0 : self.borderWidth;
        
        dot.layer.masksToBounds = YES;
        
        [_container addSubview:dot];
        [dots addObject:dot];
    }
    
    _dots = dots;
}


-(void)setPagesCount:(NSInteger)pagesCount
{
    _pagesCount  = pagesCount;
    _selectedPage = 0;
    [self setup];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _container.center = CGPointMake(0.5f * self.width, 0.5f * self.height);
}

- (void)setSelectedPage:(NSUInteger)selectedPage
{
    if (selectedPage >= _dots.count) {
        return;
    }
    UIView *curPage = _dots[_selectedPage];
    [curPage setBackgroundColor:self.color];
    [curPage.layer setBorderWidth:_borderWidth];
    _selectedPage = selectedPage;
    UIView *nextPage = _dots[_selectedPage];
    [nextPage setBackgroundColor:self.selectedColor];
    [nextPage.layer setBorderWidth:0.0];
}

@end
