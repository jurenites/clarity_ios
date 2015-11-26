//
//  VCtrlBaseTable.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/27/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCtrlBaseProtocol.h"
#import "VCtrlBaseOld.h"
#import "TableView.h"
#import "TableContentCtrl.h"

typedef BaseOnLoadMoreComplete BaseTableOnLoadMoreComplete;

@interface VCtrlBaseTable : VCtrlBaseOld

@property (strong, nonatomic) IBOutlet TableView *tableView;

- (void)triggerInfiniteScroll;
- (void)triggerReloadContentWithBlockPtr:(BOOL)blockPtr andIs:(BOOL)blockIs;
- (void)configureTable;

- (void)scrollToTop;

- (ApiCanceler *)tableReloadContent:(BaseTableOnLoadMoreComplete)onComplete;
- (ApiCanceler *)tableLoadMoreContent:(BaseTableOnLoadMoreComplete)onComplete;

- (BOOL)isNeedPullToRefresh;
- (BOOL)isNeedInfiniteScroll;

@property (assign, nonatomic) BOOL pullToRefreshEnabled;
@property (assign, nonatomic) BOOL infiniteScrollEnabled;

@property (strong, nonatomic) TableContentCtrl *contentCtrl;

@property (assign, nonatomic) CGFloat bottomInset;
@property (assign, nonatomic) CGFloat topInset;
@property (assign, nonatomic) BOOL dontAdjustInsets;

@end
