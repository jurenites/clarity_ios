//
//  PtrScrollProtocol.h
//  Yingo Yango
//
//  Created by Alexey Klyotzin on 05/10/15.
//  Copyright © 2015 LucienRucci. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PtrCtrl;

@protocol PtrScrollProtocol <NSObject>

- (NSInteger)elementsCount;
- (UIEdgeInsets)superContentInsets;
- (void)setSuperContentInsets:(UIEdgeInsets)insets;

@property (readonly, nonatomic) PtrCtrl *ptrCtrl;

@end
