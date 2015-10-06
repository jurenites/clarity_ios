//
//  SelectCtrlItem.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/2/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "UniqueObject.h"

@interface SelectCtrlItem : UniqueObject

@property (strong, nonatomic) id key;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger count;

@end
