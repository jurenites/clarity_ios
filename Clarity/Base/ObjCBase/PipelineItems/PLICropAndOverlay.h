//
//  PLICropAndOverlay.h
//  StaffApp
//
//  Created by stolyarov on 04/08/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "PipelineItem.h"

@interface PLICropAndOverlay : PipelineItem

- (instancetype)initWithDstSize:(CGSize)size blackOverlay:(BOOL) addOverlay;

@property (assign, nonatomic) BOOL fromYoutube;


@end
