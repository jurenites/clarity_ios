//
//  Entity+DB.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 4/23/14.
//
//

#import "Entity.h"
#import "Database.h"
#import "FMResultSet+DB.h"
#import "DBHelper.h"

@interface Entity (DB)

+ (void)createTableInDb:(Database *)db;

+ (void)migrateTableInDb:(Database *)db fromVersion:(NSInteger)fromVersion toVersion:(NSInteger)toVersion;

@end
