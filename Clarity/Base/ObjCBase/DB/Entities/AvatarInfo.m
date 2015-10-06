//
//  AvatarInfo.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 9/9/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "AvatarInfo.h"
#import "Entity+DB.h"

#define AVATAR_INFO_TABLE_NAME @"avatar_info"

#define AI_AVATAR_ID @"avatar_id"
#define AI_HEAD_X_POS @"head_x_pos"
#define AI_HEAD_Y_POS @"head_y_pos"
#define AI_UPDATE_TIME @"update_ime"

@implementation AvatarInfo

+ (void)createTableInDb:(Database *)db
{
    NSArray *query = @[
           @"CREATE TABLE IF NOT EXISTS `" AVATAR_INFO_TABLE_NAME @"` (",
           @"`" AI_AVATAR_ID @"` TEXT PRIMARY KEY, "
           @"`" AI_HEAD_X_POS @"` REAL NOT NULL, "
           @"`" AI_HEAD_Y_POS @"` REAL NOT NULL, "
           @"`" AI_UPDATE_TIME @"` INTEGER NOT NULL)"];
    
    [db execUpdate:query];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.avatarId = @"";
    self.updateTime = [NSDate dateWithTimeIntervalSince1970:0];
    return self;
}

- (NSDictionary *)dbGetDict
{
    return @{AI_AVATAR_ID : self.avatarId,
             AI_HEAD_X_POS : @(self.headXPos),
             AI_HEAD_Y_POS : @(self.headYPos),
             AI_UPDATE_TIME : @([self.updateTime timeIntervalSince1970])};
}

- (NSArray *)getInsertFieldsList
{
    return @[AI_AVATAR_ID, AI_HEAD_X_POS, AI_HEAD_Y_POS, AI_UPDATE_TIME];
}

- (void)dbInsert:(Database *)db
{
    [db execUpdate:@[
         @"INSERT INTO `" AVATAR_INFO_TABLE_NAME @"` ",
         [DBHelper makeInsertPart:[self getInsertFieldsList]]]
        withParams:[self dbGetDict]];
}

+ (void)dbDeleteById:(NSString *)avatarId db:(Database *)db
{
    [db execUpdate:@[@"DELETE FROM `" AVATAR_INFO_TABLE_NAME @"` WHERE " AI_AVATAR_ID @" = :" AI_AVATAR_ID]
        withParams:@{AI_AVATAR_ID : avatarId}];
}

+ (AvatarInfo *)avatarInfoWithId:(NSString *)avatarId fromDb:(Database *)db
{
    FMResultSet *res = [db exec:@[@"SELECT * FROM " AVATAR_INFO_TABLE_NAME @" "
                                  @"WHERE " AI_AVATAR_ID @" = :" AI_AVATAR_ID]
                     withParams:@{AI_AVATAR_ID: avatarId}];
    
    if ([res next]) {
        AvatarInfo *ai = [AvatarInfo new];
        
        [ai dbFillWithResult:res];
        [res close];
        return ai;
    }
    
    [res close];
    return nil;
}

- (void)dbFillWithResult:(FMResultSet *)res
{
    self.avatarId = [res stringCol:AI_AVATAR_ID];
    self.headXPos = [res floatCol:AI_HEAD_X_POS];
    self.headYPos = [res floatCol:AI_HEAD_Y_POS];
    self.updateTime = [res dateCol:AI_UPDATE_TIME];
}

@end
