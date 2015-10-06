//
//  VCtrlSideBar.h
//  TRN
//
//  Created by stolyarov on 31/03/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "VCtrlBase.h"

@interface VCtrlSideBar : VCtrlBase

+ (instancetype)current;

- (void)pushMenu;
- (void)showMenu;
- (void)popMenuAnimated:(BOOL)animated;
- (void)showMenuWithHelpshiftData:(NSDictionary *)userInfo;

- (void)setVCtrlsForPush:(NSArray *)vctrls;
- (BOOL)menuIsOpened;
@end
