//
//  TableContentCtrl.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ImageCache.h"
#import "VCtrlBaseProtocol.h"

@class TableContentCtrl, VCtrlBaseTable;

@protocol TableContentCtrlDelegate <NSObject>

@end


@interface TableContentCtrl : NSObject

+ (NSArray *)trimVisibleRows:(NSArray *)visibleRows forIndexPath:(NSIndexPath *)indexPath;

- (instancetype)initWithTable:(UITableView *)table;

- (instancetype)initWithTable:(UITableView *)table
                   imageCache:(ImageCache *)imageCache;

- (BOOL)shouldPresentPopup;

- (CGFloat)cachedScreens;

- (CGFloat)rowHeightAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathFromIndex:(NSUInteger)index;

- (UIImage *)cachedImageAtRow:(NSUInteger)row;

- (void)deleteRowsAtIndexPaths:(NSArray *)paths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)itemsWasAddedWithPrevCount:(NSUInteger)prevCount;
- (void)reloadData;

- (void)memoryWarningReceived;
- (void)restartRequests;


@property (readonly, nonatomic) NSUInteger rowsCount;
@property (readonly, nonatomic) ImageCache *imageCache;

@property (strong, nonatomic) NSIndexPath *startIndexPath;
@property (assign, nonatomic) BOOL isActive;

@property (weak, nonatomic) VCtrlBaseTable *viewController;

@end


