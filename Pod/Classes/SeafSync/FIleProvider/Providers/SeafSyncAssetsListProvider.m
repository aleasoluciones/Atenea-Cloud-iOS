//
//  SeafSyncAssetsListProvider.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 16/11/23.
//

#import "SeafSyncAssetsListProvider.h"
#import "SeafSyncAssetItem.h"
#import "SeafPhotoAsset.h"

/**
 *  SeafSyncAssetsListProvider ()
 * @brief Private interface for SeafSyncAssetsListProvider.
 */
@interface SeafSyncAssetsListProvider()

@property (nonatomic, retain) NSArray<PHAsset *> *assets;

@end


@implementation SeafSyncAssetsListProvider

/**
 * Initializes a new instance of SeafSyncGalleryProvider with the specified album name.
 * @param assets The assets array to return on getFiles
 * @return An initialized instance of SeafSyncGalleryProvider.
 */
- (id)initWithPHAssets:(NSArray<PHAsset *> *)assets{
    self = [super init];
    if (self) {
        self.assets = assets;
    }
    return self;
}

/**
 * Gets the list of items in the synchronized gallery or album.
 * @param onError An optional error pointer.
 * @return An array of objects conforming to the SeafSyncItemProtocol representing the items in the gallery or album.
 */
- (NSMutableArray<SeafSyncAssetItem *> *)getFiles:(NSError **)onError {
    return [self createSeafPhotoAssets];
}


/**
 * Iterates through assets in the gallery and processes them.
 * @return An array of SeafSyncAssetItem objects representing the processed assets.
 */
- (NSMutableArray<SeafSyncAssetItem *> *)createSeafPhotoAssets {
    NSMutableArray<SeafSyncAssetItem *> *files = [[NSMutableArray<SeafSyncAssetItem *> alloc] init];
    [self.assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [files addObject:[[SeafSyncAssetItem alloc] initWithPHAsset:asset]];
    }];
    return files;
}

@end
