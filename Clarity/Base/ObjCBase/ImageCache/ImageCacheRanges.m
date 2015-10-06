//
//  ImageCacheRanges.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/13/14.
//
//

#import "ImageCacheRanges.h"

@implementation ImageCacheRanges

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.fullRange = NSMakeRange(0, 0);
    self.visibleRange = NSMakeRange(0, 0);
    
    return self;
}

@end
