//
//  NSIndexPath+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/20/14.
//
//

#import "NSIndexPath+Utils.h"

@implementation NSIndexPath (Utils)

- (NSIndexPath *)add:(NSIndexPath *)indexPath
{
    return [NSIndexPath indexPathForRow:self.row + indexPath.row
                              inSection:self.section + indexPath.section];
}

@end
