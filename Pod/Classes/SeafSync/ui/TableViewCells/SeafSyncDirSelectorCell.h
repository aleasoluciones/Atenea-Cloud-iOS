//
//  SeafSyncDirSelectorCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 9/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafDir.h"
#import "SeafSyncDirSelectorViewController.h"
#import "SeafConnection.h"
#import "SeafSyncBaseUITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SeafSyncDirSelectorCellCallback)(SeafDir *directory);


@interface SeafSyncDirSelectorCell : SeafSyncBaseUITableViewCell<SeafSyncDirSelectorViewControllerDelegate>

- (void) onDirectorySelected:(SeafSyncDirSelectorCellCallback) callback;

- (void) setTitle:(NSString *) title;

- (void) setDirectoryPath:(NSString *) directoryPath;

- (void) setConnection:(SeafConnection *) connection;

@end


NS_ASSUME_NONNULL_END
