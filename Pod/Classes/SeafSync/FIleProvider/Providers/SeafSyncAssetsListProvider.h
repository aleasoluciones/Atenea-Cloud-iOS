//
//  SeafSyncAssetsListProvider.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 16/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"
#import "SeafSyncProviderProtocol.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncAssetsListProvider : NSObject<SeafSyncProviderProtocol>

/**
 * Initializes a new instance of SeafSyncGalleryProvider with the specified album name.
 * @param assets The assets array
 * @return An initialized instance of SeafSyncGalleryProvider.
 */
- (id)initWithPHAssets:(NSArray<PHAsset *> *)assets;

/**
 * Gets the list of items in the synchronized gallery or album.
 * @param onError An optional error pointer.
 * @return An array of objects conforming to the SeafSyncItemProtocol representing the items in the gallery or album.
 */
- (NSMutableArray<id<SeafSyncItemProtocol>> *)getFiles:(NSError **)onError;

@end

NS_ASSUME_NONNULL_END
