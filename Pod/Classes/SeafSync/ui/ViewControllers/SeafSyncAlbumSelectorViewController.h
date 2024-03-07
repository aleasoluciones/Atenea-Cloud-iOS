//
//  SeafSyncAlbumSelectorViewController.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN


@protocol SeafSyncAlbumSelectorViewControllerDelegate

-(void) onSelectAlbum:(PHAssetCollection *) assetCollection;

@end

@interface SeafSyncAlbumSelectorViewController : UIViewController <PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate>

-(id) initWithDelegate:(id<SeafSyncAlbumSelectorViewControllerDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
