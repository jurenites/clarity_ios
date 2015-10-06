//
//  TextLayout.h
//  Brabble-iOSClient
//
//  Created by stolyarov on 23/12/2013.
//  Copyright (c) 2013 stolyarov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextLayoutInfo : NSObject

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, readonly) NSArray *words;
@property (nonatomic, readonly) NSArray *shortenedWords;
@property (nonatomic, readonly) NSAttributedString *attrString;
@property (nonatomic, readonly) NSMutableAttributedString *shortenedAttrString;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGSize shortenedSize;

+ (NSMutableAttributedString *)buildShortenedAttrStringFromString:(NSMutableAttributedString *)attrString
                                                         forWidth:(CGFloat) width
                                                        dotsColor:(UIColor *)dotsColor;

+(CGFloat)heightForAttributedString:(NSAttributedString *)attrString
                           forWidth:(CGFloat)inWidth
                   forExclusionRect:(CGRect)exclusionRect;
@end
