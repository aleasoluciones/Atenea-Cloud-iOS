//
//  SeafSyncAlbumCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncAlbumSelectorViewController.h"
#import "SeafSyncBaseUITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SeafSyncAlbumCellCallback)(NSString *albumName);


@interface SeafSyncAlbumCell : SeafSyncBaseUITableViewCell<SeafSyncAlbumSelectorViewControllerDelegate>

- (void) onAlbumSelected:(SeafSyncAlbumCellCallback) callback;

- (void) setTitle:(NSString *) title;

- (void) setAlbum:(NSString *) albumName;

@end


NS_ASSUME_NONNULL_END
