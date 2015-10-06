//
//  FMDatabase+DB.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import "FMDatabase+DB.h"
#import "NSArray+DB.h"

@implementation FMDatabase (DB)

- (void)execUpdateWithString:(NSString *)sql withParams:(NSDictionary *)arguments
{
    if (![self executeUpdate:sql withParameterDictionary:arguments]) {
        [NSException raise:@"Query error" format:@"%@", self.lastErrorMessage];
    }
}

- (void)execUpdateWithString:(NSString *)sql
{
    if (![self executeUpdate:sql]) {
        [NSException raise:@"Query error" format:@"%@", self.lastErrorMessage];
    }
}

- (FMResultSet *)execWithString:(NSString *)sql withParams:(NSDictionary *)arguments
{
    FMResultSet *res = [self executeQuery:sql withParameterDictionary:arguments];
    
    if (!res) {
        [NSException raise:@"Query error" format:@"%@", self.lastErrorMessage];
    }
    
    return res;
}

- (FMResultSet *)execWithString:(NSString *)sql
{
    FMResultSet *res = [self executeQuery:sql];
    
    if (!res) {
        [NSException raise:@"Query error" format:@"%@", self.lastErrorMessage];
    }
    
    return res;
}

- (void)execUpdate:(NSArray *)sql withParams:(NSDictionary *)arguments
{
    [self execUpdateWithString:[sql join] withParams:arguments];
}

- (void)execUpdate:(NSArray *)sql
{
    [self execUpdateWithString:[sql join]];
}

- (FMResultSet *)exec:(NSArray *)sql withParams:(NSDictionary *)arguments
{
    return [self execWithString:[sql join] withParams:arguments];
}

- (FMResultSet *)exec:(NSArray *)sql
{
    return [self execWithString:[sql join]];
}

@end
