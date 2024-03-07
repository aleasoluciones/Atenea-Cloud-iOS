//
//  SeafSyncDateCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncBaseUITableViewCell.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^SeafSyncDateCellCallback)(NSDate *value);


@interface SeafSyncDateCell : SeafSyncBaseUITableViewCell

- (void) onDateChange:(SeafSyncDateCellCallback) callback;

- (void) setTitle:(NSString *) title;

- (void) setDate:(NSDate *) date;

@end

NS_ASSUME_NONNULL_END
