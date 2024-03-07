//
//  SeafSyncDeviceFolderCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncBaseUITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN


typedef void (^SeafSyncDeviceFolderCellCallback)(NSData *bookmark);


@interface SeafSyncDeviceFolderCell : SeafSyncBaseUITableViewCell<UIDocumentPickerDelegate>

- (void) onFolderSelected:(SeafSyncDeviceFolderCellCallback) callback;

- (void) setTitle:(NSString *) title;

- (void) setFolderURL:(NSURL *) folderURL;

@end


NS_ASSUME_NONNULL_END
