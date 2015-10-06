//
//  ContentOffsetKVO.h
//  Valkyrie
//
//  Created by Alexey Klyotzin on 1/15/15.
//  Copyright (c) 2015 Life Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContentOffsetKVO : NSObject

- (instancetype)initWithObject:(NSObject *)object onChange:(void(^)(CGFloat newOffset))onChange;

@end
