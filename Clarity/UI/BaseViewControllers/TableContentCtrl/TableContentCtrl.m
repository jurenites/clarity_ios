//
//  TableContentCtrl.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/13/13.
//
//

#import "TableContentCtrl.h"
#import "TableContentCtrl_Private.h"
#import "InternalError.h"
#import "IOManager.h"
#import "ApiRouter.h"

static const CGFloat UpdateCacheTreshold = 50;

@interface TableContentCtrl ()
{
    CGFloat _prevYContentOffset;
    BOOL _popupIsDenied;
}

@end

@implementation TableContentCtrl

@dynamic delegate;

- (instancetype)initWithTable:(UITableView *)table
{
    self = [super init];
    if (!self)
        return nil;
    
    _table = table;
    _startIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    return self;
}

- (instancetype)initWithTable:(UITableView *)table
                   imageCache:(ImageCache *)imageCache
{
    self = [self initWithTable:table];
    if (!self)
        return nil;
    
    _imageCache = imageCache;
    
    [_table addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    return self;
}

- (void)dealloc
{
    if (_imageCache) {
        [_table removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (BOOL)shouldPresentPopup
{
    if (_popupIsDenied) {
        return NO;
    }
    
    _popupIsDenied = YES;
    
    DispatchAfter(0.5f, ^{
        _popupIsDenied = NO;
    });
    
    return YES;
}

- (NSUInteger)rowsCount
{
    return 0;
}

- (CGFloat)getRowHeight:(NSInteger)row
{
    return 0;
}

- (UITableViewCell *)getCellForRow:(NSInteger)row
{
    return nil;
}

- (NSUInteger)indexPathToIndex:(NSIndexPath *)indexPath
{
    if (!self.startIndexPath) {
        return indexPath.row;
    }
    
    return indexPath.row - self.startIndexPath.row;
}

- (CGFloat)rowHeightAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getRowHeight:[self indexPathToIndex:indexPath]];
}

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getCellForRow:[self indexPathToIndex:indexPath]];
}

- (NSIndexPath *)indexPathFromIndex:(NSUInteger)index
{
    return [NSIndexPath indexPathForItem:self.startIndexPath.item + index inSection:self.startIndexPath.section];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)paths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.imageCache && self.isActive) {
        [self.imageCache rebuildWithTableAction:^{
            [self.table deleteRowsAtIndexPaths:paths withRowAnimation:animation];
        }];
    } else {
        [self.table deleteRowsAtIndexPaths:paths withRowAnimation:animation];
    }
}

+ (NSArray *)trimVisibleRows:(NSArray *)visibleRows forIndexPath:(NSIndexPath *)startIndexPath
{
    if (visibleRows.count == 0) {
        return @[];
    }
    
    NSIndexPath *first = visibleRows.firstObject;
    NSIndexPath *last = visibleRows.lastObject;
    
    if (first.section > startIndexPath.section
        || [last compare:startIndexPath] == NSOrderedAscending) {
        return @[];
    }
    
    NSUInteger firstIndex = 0;
    NSUInteger lastIndex = visibleRows.count - 1;
    
    for (; firstIndex < visibleRows.count; firstIndex++) {
        NSIndexPath *indexPath = visibleRows[firstIndex];
        NSComparisonResult cmpResult = [indexPath compare:startIndexPath];
        
        if (cmpResult == NSOrderedSame || cmpResult == NSOrderedDescending) {
            break;
        }
    }
    
    if (firstIndex >= visibleRows.count) {
        return @[];
    }
    
    for (; lastIndex < visibleRows.count; lastIndex--) {
        NSIndexPath *indexPath = visibleRows[lastIndex];
        
        if (indexPath.section == startIndexPath.section) {
            break;
        }
    }
    
    if (lastIndex >= visibleRows.count || lastIndex < firstIndex) {
        return @[];
    }
    
    return [visibleRows subarrayWithRange:NSMakeRange(firstIndex, lastIndex - firstIndex + 1)];
}

- (UIImage *)unrollSingleImage:(ImageCacheResult *)result
{
    __block UIImage *cachedImage = nil;
    
    [result enumerateWithBlock:^(ImageCacheRequest *req, UIImage *image, BOOL *stop) {
        cachedImage = image;
    }];
    
    return cachedImage;
}

- (UIImage *)cachedImageAtRow:(NSUInteger)row
{
    return [self unrollSingleImage:[self.imageCache getImagesAtIndex:row]];
}

- (CGFloat)cachedScreens
{
    return 1.5f;
}

- (ImageCacheRanges *)getCachingRange
{
    const CGFloat cachedSpace = self.table.frame.size.height * [self cachedScreens];
    NSArray *actualVisibleRows = [self.table indexPathsForVisibleRows];
    NSArray *visibleRows = [[self class] trimVisibleRows:actualVisibleRows
                                            forIndexPath:self.startIndexPath];
    
    ImageCacheRanges *ranges = [ImageCacheRanges new];
    NSInteger rowsCount = [self rowsCount];
    
    if (!visibleRows.count) {
        const NSUInteger rowsInTb = [self.table numberOfRowsInSection:self.startIndexPath.section];
        
        if (rowsCount == 0 || rowsInTb == 0 || rowsInTb == NSNotFound) {
            return ranges;
        } else if (actualVisibleRows.count
            && [self.startIndexPath compare:actualVisibleRows.firstObject] == NSOrderedAscending) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.startIndexPath.row + rowsInTb - 1
                                                   inSection:self.startIndexPath.section];
            visibleRows = @[path];
        } else {
            visibleRows = @[self.startIndexPath];
        }
    }
    
    // first and last are in table view index space
    NSIndexPath *first = visibleRows.firstObject;
    NSIndexPath *last = visibleRows.lastObject;
        
    CGRect firstFrame = [self.table rectForRowAtIndexPath:first];
    CGRect lastFrame = [self.table rectForRowAtIndexPath:last];
    
    NSInteger firstIndex = first.row;
    NSInteger lastIndex = last.row;
    
    // firstIndex and lastIndex are in table controller index space
    firstIndex -= self.startIndexPath.row;
    lastIndex -= self.startIndexPath.row;
    
    firstIndex = MAX(0, firstIndex);
    lastIndex = MIN(rowsCount - 1, lastIndex);
    
    ranges.visibleRange = NSMakeRange(firstIndex, lastIndex - firstIndex + 1);
    
    CGFloat upper = self.table.contentOffset.y - firstFrame.origin.y;
    
    while (upper < cachedSpace && firstIndex > 0) {
        upper += [self getRowHeight:(--firstIndex)];
    }
    
    firstIndex = MAX(firstIndex, 0);
    
    CGFloat lower = (lastFrame.origin.y + lastFrame.size.height) - (self.table.contentOffset.y + self.table.frame.size.height);
    
    while (lower < cachedSpace && lastIndex < ((NSInteger)[self rowsCount] - 1)) {
        lower += [self getRowHeight:(++lastIndex)];
    }
    
    lastIndex = MIN(lastIndex + 1, (NSInteger)[self rowsCount]);
    
    ranges.fullRange = NSMakeRange(
        firstIndex,
        (lastIndex > firstIndex) ? (lastIndex - firstIndex) : 0);
    
    return ranges;
}

- (UITableViewCell *)getCellAtIndex:(NSUInteger)index
{
    NSUInteger section = self.startIndexPath.section;
    NSUInteger row = index + self.startIndexPath.row;
    
    return [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (void)reloadData
{
    if (self.isActive && self.imageCache) {
        [self.imageCache rebuild];
    } else {
        [self.table reloadData];
    }
    
    [self.viewController checkPlacehoder];
}

- (void)itemsWasAddedWithPrevCount:(NSUInteger)prevCount
{
    if (self.isActive) {
        [self.table reloadData];
        [self.imageCache update];
    }
    
    [self.viewController checkPlacehoder];
}

- (void)memoryWarningReceived
{
    [self.imageCache clear];
}

- (void)restartRequests
{
    [self.imageCache restartRequests];
}

- (void)setIsActive:(BOOL)isActive
{
    if (!_isActive && isActive) {
        if (self.imageCache) {
            [self.imageCache rebuild];
            [self.imageCache restartRequests];
        } else {
            [self.table reloadData];
        }
    }
    else if (_isActive && !isActive) {
        [self.imageCache cancelPendingRequests];
    }
    
    _isActive = isActive;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (self.isActive && [keyPath isEqualToString:@"contentOffset"]) {
        if (fabs(_table.contentOffset.y - _prevYContentOffset) > UpdateCacheTreshold) {
            _prevYContentOffset = _table.contentOffset.y;
            [_imageCache update];
        }
    }
}

#pragma mark -- image cache delegate

- (ImageCacheRanges *)imageCacheGetRange:(ImageCache *)cache
{
    return [self getCachingRange];
}

- (void)imageCacheReloadTable:(ImageCache *)cache
{
    [self.table reloadData];
}

- (NSArray *)imageCache:(ImageCache *)cache itemsAtIndex:(NSInteger)index
{
    [[InternalError errorWithDescr:@"[TableContentCtrl imageCache:itemsAtIndex:] not implemented"] raise];
    return nil;
}

- (void)imageCache:(ImageCache *)cache
        imageReady:(UIImage *)image
         cacheItem:(ImageCacheRequest *)item
           atIndex:(NSInteger)index
{
    [[InternalError errorWithDescr:@"[TableContentCtrl imageCache:imageReady:] not implemented"] raise];
}

- (ApiCanceler *)imageCache:(ImageCache *)cache
            runNetOpForItem:(ImageCacheRequest *)item
                  onSuccess:(void(^)(UIImage *))onSuccess
                    onError:(void(^)(NSError *))onError
{
    [[InternalError errorWithDescr:@"[TableContentCtrl imageCache:runNetOpForItem:] not implemented"] raise];
    return nil;
}

- (void)imageCache:(ImageCache *)cache reorderRequests:(NSOrderedSet *)requests
{
    IOManager *iom = [ApiRouter shared].mediaIO;
    NSMutableArray *reqIds = [NSMutableArray arrayWithCapacity:requests.count];
    
    for (ApiCanceler *canceler in requests) {
        if (canceler.impl.ioManager != (__bridge const void *)iom) {
            continue;
        }
        
        UniqueNumber *requestId = canceler.impl.requestId;
        
        if (requestId) {
            [reqIds addObject:requestId];
        }
    }
    
    [iom reorderRequests:reqIds];
}

@end
