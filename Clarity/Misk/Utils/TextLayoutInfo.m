//
//  TextLayout.m
//  Brabble-iOSClient
//
//  Created by stolyarov on 23/12/2013.
//  Copyright (c) 2013 stolyarov. All rights reserved.
//

#import "TextLayoutInfo.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "DeviceHardware.h"


@implementation TextLayoutInfo

+ (NSMutableAttributedString *)buildShortenedAttrStringFromString:(NSMutableAttributedString *)attrString
                                                         forWidth:(CGFloat) width
                                                        dotsColor:(UIColor *)dotsColor
{
    if (!attrString.length) {
        return nil;
    }
    NSMutableAttributedString *shortenedAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];
    
    CFIndex numberOfLines = 2;
    // write frame for text
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(shortenedAttrString));
    
    // Create the frame and draw it into the graphics context
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, (CGRect){0, 0, width, [self calculateSize:attrString forWidth:width].height});
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    // buttons for targets
    CFArrayRef linesRef = CTFrameGetLines(frame);
    if (CFArrayGetCount(linesRef) > numberOfLines) {
        const CFIndex finalLineIdx = numberOfLines - 1;
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[attrString attributesAtIndex:0 effectiveRange:NULL]];
        [attributes setObject:dotsColor forKey:NSForegroundColorAttributeName];
        
        
        CTLineRef line = CFArrayGetValueAtIndex(linesRef, finalLineIdx);
        CFRange lineRange = CTLineGetStringRange(line);
        
        // Get current line attributed string
        NSMutableAttributedString *lineStr = (NSMutableAttributedString *)[shortenedAttrString attributedSubstringFromRange:NSMakeRange(lineRange.location, lineRange.length)];
        
        // Trim trailing whitespace from string
        // Such complex because mention/hashtag highlighting breaks with simple method
        NSMutableAttributedString *newLineStr = [lineStr mutableCopy];
        NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSRange trimRange = [newLineStr.string rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
        while (trimRange.length != 0 && NSMaxRange(trimRange) == newLineStr.length)
        {
            [newLineStr deleteCharactersInRange:trimRange];
            trimRange = [newLineStr.string rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
        }
        
        
        
        // Calculate size of trailed string
        CGSize lineSize = [self calculateSize:newLineStr forWidth:width];
        
        // Prepare attributed string of ellipsis
        NSAttributedString *dotsStr = [[NSAttributedString alloc] initWithString:@"...More" attributes:attributes];
        CFIndex clipLength = dotsStr.length;
        // Calculate size of ellipsis attributed string
        CGSize dotsSize = [self calculateSize:dotsStr forWidth:width];
        
        // Ellipsis can fit in existing bounds
        if (width - lineSize.width > dotsSize.width) {
            clipLength = 0;
        }
        // Replace or add ellipsis to string
        if (clipLength != 0) {
            NSRange exchangeRange = NSMakeRange(newLineStr.length - clipLength, clipLength);
            
            NSAttributedString *suffix = [newLineStr attributedSubstringFromRange:exchangeRange];
            CGSize endingSize = [self calculateSize:suffix forWidth:width];
            // Get ending width more than ellipsis width to avoid line break
            while (endingSize.width < dotsSize.width) {
                if (exchangeRange.location == 0 ||
                    NSMaxRange(exchangeRange) > newLineStr.length) {
                    break;
                }
                
                exchangeRange.location--;
                exchangeRange.length++;
                
//                suffix = [newLineStr attributedSubstringFromRange:exchangeRange];
                endingSize = [self calculateSize:attrString forWidth:width];
            }
            
            [newLineStr replaceCharactersInRange:exchangeRange withAttributedString:dotsStr];
        } else {
            [newLineStr appendAttributedString:dotsStr];
        }
        // Replace unneded 3+ strings with new truncated string
        NSRange replaceRange = NSMakeRange(lineRange.location, shortenedAttrString.length - lineRange.location);
        [shortenedAttrString replaceCharactersInRange:replaceRange withAttributedString:newLineStr];
        
    }
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);
    
    return shortenedAttrString;
}



+ (CGSize)calculateSize:(NSAttributedString *)attrString forWidth:(CGFloat)width
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    CGSize targetSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attrString length]), NULL, targetSize, NULL);
    CFRelease(framesetter);
    
    return fitSize;
}

+(CGFloat)heightForAttributedString:(NSAttributedString *)attrString
                           forWidth:(CGFloat)inWidth
                   forExclusionRect:(CGRect)exclusionRect
{
    if (!attrString) {
        return 0;
    }
    CGRect mainRect = CGRectMake(0,0, inWidth, 20000);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, mainRect);
    
    CGRect clipRect = (CGRect){0, mainRect.size.height - exclusionRect.size.height, exclusionRect.size};
    CGPathAddRect(path, NULL, clipRect);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attrString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CFArrayRef lineArray = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lineArray);
    CGFloat descent;
    CGPoint lastLineOrigin;
    
    CGFloat H = 0;
    
    if (lineCount) {
        CTFrameGetLineOrigins(frame, CFRangeMake((CFIndex)lineCount - 1 , 1), &lastLineOrigin);
        CTLineRef lastLine = (CTLineRef) CFArrayGetValueAtIndex(lineArray, (CFIndex)lineCount - 1);
        CTLineGetTypographicBounds(lastLine, NULL, &descent, NULL);
        
        H = (CGRectGetMaxY(mainRect) - lastLineOrigin.y + descent);
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    return ceilf(H);
}


@end
