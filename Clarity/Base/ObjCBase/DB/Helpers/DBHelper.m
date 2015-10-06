//
//  DBHelper.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import "DBHelper.h"

@implementation DBHelper

+(NSString*)makeInsertPart:(NSArray*)fieldNames
{
    NSMutableArray *fields = [NSMutableArray array];
    NSMutableArray *placeholders = [NSMutableArray array];
    
    for (NSString *field in fieldNames)
    {
        [fields addObject:[NSString stringWithFormat:@"`%@`", field]];
        [placeholders addObject:[NSString stringWithFormat:@":%@", field]];
    }
    
    return
        [NSString
            stringWithFormat:@"(%@) VALUES (%@)",
            [fields componentsJoinedByString:@", "],
            [placeholders componentsJoinedByString:@", "]];
}

+(NSString*)makeUpdatePart:(NSArray*)fieldNames
{
    NSMutableArray *fields = [NSMutableArray array];
    
    for (NSString *field in fieldNames)
    {
        [fields addObject:[NSString stringWithFormat:@"`%@` = :%@", field, field]];
    }
    
    return [fields componentsJoinedByString:@", "];
}

@end
