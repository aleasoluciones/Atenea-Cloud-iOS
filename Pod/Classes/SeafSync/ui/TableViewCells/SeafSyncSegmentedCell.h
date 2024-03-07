//
//  SeafSyncSegmentedCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncBaseUITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN


typedef void (^SeafSyncSegmentedCellCallback)(NSInteger selectedIndex);


@interface SeafSyncSegmentedCell : SeafSyncBaseUITableViewCell

- (void) onSegmentSelected:(SeafSyncSegmentedCellCallback) callback;

- (void) setTitle:(NSString *) title;

- (void) setSelectedSegmentIndex:(NSInteger) selectedSegment;

- (void) setSegments:(NSArray<NSString *> *) segments;

@end




NS_ASSUME_NONNULL_END
