//
//  AvatarInfo.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 9/9/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "Entity.h"
#import "Entity+DB.h"

@interface AvatarInfo : Entity

+ (AvatarInfo *)avatarInfoWithId:(NSString *)avatarId fromDb:(Database *)db;
+ (void)dbDeleteById:(NSString *)avatarId db:(Database *)db;

- (void)dbInsert:(Database *)db;

@property (strong, nonatomic) NSString *avatarId;
@property (assign, nonatomic) CGFloat headXPos;
@property (assign, nonatomic) CGFloat headYPos;
@property (strong, nonatomic) NSDate *updateTime;

@end
