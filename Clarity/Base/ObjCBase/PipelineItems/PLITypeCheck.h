//
//  PLITypeCheck.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/14/14.
//
//

#import "PipelineItem.h"

@interface PLITypeCheck : PipelineItem

+ (id)PLIIsDictionary;
+ (id)PLIIsArray;

- (instancetype)initWithClass:(Class)classObj;

@end
