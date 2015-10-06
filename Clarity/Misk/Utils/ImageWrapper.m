//
//  ImageWrapper.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/14/13.
//
//

#import "ImageWrapper.h"

@implementation ImageWrapper

-(id)initWithImage:(UIImage*)image
{
    self = [super init];
    if (!self)
        return nil;
    
    self.image = image;
    return self;
}

@end
