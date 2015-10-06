//
//  VCtrlNavigation.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/26/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RootTypeLogin,
    RootTypeUser,
} RootType;

@interface VCtrlNavigation : UINavigationController

+ (instancetype)current;
+ (instancetype)createWithRootVC:(UIViewController *)vc;

- (void)setRootVCtrl:(UIViewController *)vctrl animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)setVCtrl:(UIViewController *)vctrl atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addVCtrl:(UIViewController *)vctrl animated:(BOOL)animated;

- (void)updateTimerLabel:(NSString *)time;

@property (assign, nonatomic) BOOL navBarDisabled;

- (void)willAppear;
- (void)showPromoBtn:(BOOL)animated;
- (void)hidePromoBtn:(BOOL)animated;

@end
