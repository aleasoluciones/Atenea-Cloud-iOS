//
//  SeafSyncGalleryProvider.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"
#import "SeafSyncProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @interface SeafSyncGalleryProvider
 * @brief A class representing a provider for synchronizing items from a gallery or album.
 */
@interface SeafSyncGalleryProvider : NSObject<SeafSyncProviderProtocol>

/**
 * Initializes a new instance of SeafSyncGalleryProvider with the specified album name.
 * @param albumName The name of the gallery or album to synchronize.
 * @return An initialized instance of SeafSyncGalleryProvider.
 */
- (id)initWithAlbumName:(NSString *)albumName;

/**
 * Gets the list of items in the synchronized gallery or album.
 * @param onError An optional error pointer.
 * @return An array of objects conforming to the SeafSyncItemProtocol representing the items in the gallery or album.
 */
- (NSMutableArray<id<SeafSyncItemProtocol>> *)getFiles:(NSError **)onError;

@end

NS_ASSUME_NONNULL_END
