//
//  TableView.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 4/30/14.
//
//

#import <UIKit/UIKit.h>

@class TableView;

@protocol TableViewDelegate <NSObject>

- (void)tableView:(TableView *)tableView ptrTriggered:(void(^)(BOOL hasMoreData))onComplete;
- (void)tableView:(TableView *)tableView infsTriggered:(void(^)(BOOL hasMoreData))onComplete;
- (void)tableViewDidReloadData:(TableView *)tableView;

@end

@protocol TableViewEventDelegate <NSObject>

@optional
- (void)tableViewDidLayoutSubviews:(TableView *)tableView;

@end

@interface TableView : UITableView

- (void)showSpinner;
- (void)hideSpinner;

- (void)triggerInfs;
- (void)checkForInfs;

- (void)cancelPtrLoading;
- (void)cancelInfsLoading;
- (void)resetInfiniteScrolling:(BOOL)hasData;

- (void)scrollToTop;

- (void)setTopInset:(CGFloat)topInset animated:(BOOL)animated;

@property (assign, nonatomic) BOOL shiftPtrByInsets;

@property (assign, nonatomic) BOOL ptrEnabled;
@property (assign, nonatomic) BOOL infsEnabled;
@property (assign, nonatomic) CGFloat infsTriggerTreshold;

@property (weak, nonatomic) id<TableViewDelegate> ptrDelegate;

@end
