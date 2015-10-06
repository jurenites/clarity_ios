//
//  Database.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/9/14.
//
//

#import "FMDatabase.h"
#import "FMDatabase+DB.h"

@interface Database : FMDatabase

- (void)checkFieldWithName:(NSString *)name type:(NSString *)type inTable:(NSString *)tableName;

@end
