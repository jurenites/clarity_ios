//
//  TablePtrView.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 5/5/14.
//
//

#import <UIKit/UIKit.h>

@interface TablePtrView : UIView

- (void)switchToDefaultStateAnimated:(BOOL)animated;
- (void)switchToReleaseState;
- (void)switchToLoadingState;

@end
