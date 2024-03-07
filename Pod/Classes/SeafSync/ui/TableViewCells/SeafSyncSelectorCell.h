//
//  SeafSyncSelectorCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 14/11/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncSelectorCellDataItemProtocol.h"
#import "SeafSyncBaseUITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN


typedef void (^SeafSyncSelectorCellCallback)(NSArray<id<SeafSyncSelectorCellDataItemProtocol>>* value);


@interface SeafSyncSelectorCell : SeafSyncBaseUITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource>

- (void) onValueChange:(SeafSyncSelectorCellCallback) callback;

- (void) setTitle:(NSString *) title;

- (void)setValues:(NSArray<NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *> *)values ;

- (void)selectedItems:(NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *)items ;

@end

NS_ASSUME_NONNULL_END
