//
//  ContentOffsetKVO.m
//  Valkyrie
//
//  Created by Alexey Klyotzin on 1/15/15.
//  Copyright (c) 2015 Life Church. All rights reserved.
//

#import "ContentOffsetKVO.h"

@interface ContentOffsetKVO ()
{
    NSObject *_object;
    void (^_onChange)(CGFloat);
}
@end

@implementation ContentOffsetKVO

- (instancetype)initWithObject:(NSObject *)object onChange:(void (^)(CGFloat))onChange
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _object = object;
    _onChange = [onChange copy];
    
    [object addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        _onChange([[change objectForKey:NSKeyValueChangeNewKey] floatValue]);
    }
}


@end
