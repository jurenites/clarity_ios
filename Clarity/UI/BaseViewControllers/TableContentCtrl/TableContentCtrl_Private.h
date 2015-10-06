//
//  TableContentCtrl_Private.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/6/14.
//
//

#import "TableContentCtrl.h"
#import "VCtrlBaseTable.h"

@interface TableContentCtrl () <ImageCacheDelegate>

//=======Override methods================
- (CGFloat)getRowHeight:(NSInteger)row;
- (UITableViewCell *)getCellForRow:(NSInteger)row;

//--------------------------------------------------------
- (UITableViewCell *)getCellAtIndex:(NSUInteger)index;
- (ImageCacheRanges *)getCachingRange;

@property (readonly, nonatomic) UITableView *table;
@property (weak, nonatomic) id<TableContentCtrlDelegate> delegate;

@end
