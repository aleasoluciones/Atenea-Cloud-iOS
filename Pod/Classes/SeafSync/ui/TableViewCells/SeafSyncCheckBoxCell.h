//
//  SeafSyncCheckBoxCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncBaseUITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN


typedef void (^SeafSyncCheckBoxCellCallback)(BOOL value);


@interface SeafSyncCheckBoxCell : SeafSyncBaseUITableViewCell

- (void) onSwitchChange:(SeafSyncCheckBoxCellCallback) callback;

- (void) setTitle:(NSString *) title;

- (void) setValue:(BOOL) value;

@end

NS_ASSUME_NONNULL_END
