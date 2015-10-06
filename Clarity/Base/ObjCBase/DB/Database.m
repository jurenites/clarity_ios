//
//  Database.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/9/14.
//
//

#import "Database.h"
#import "FMResultSet+DB.h"

@implementation Database

- (void)checkFieldWithName:(NSString *)name type:(NSString *)type inTable:(NSString *)tableName
{
    FMResultSet *result = [self execWithString:[NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName]];
    
    while ([result next]) {
        NSString *fieldName = [result stringCol:@"name"];
        
        if ([name isEqualToString:fieldName]) {
            return;
        }
    }
    
    [self execUpdateWithString:
     [NSString stringWithFormat:@"ALTER TABLE `%@` ADD `%@` %@", tableName, name, type]];
}

@end
