//
//  SeafSyncGalleryEnqueuer.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 2/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafEnqueuerProtocol.h"
#import "SeafSyncProviderProtocol.h"
#import "SeafConnection.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncGalleryEnqueuer : NSObject<SeafEnqueuerProtocol>

/**
 * @brief Custom initializer for SeafSyncGalleryEnqueuer.
 *
 * @param settings The synchronization settings.
 * @param connection The connection object.
 * @return An instance of SeafSyncGalleryEnqueuer.
 */
- (id)init:(SeafSyncSettings *)settings connection:(SeafConnection *)connection;

/**

  @brief Custom initializer for SeafSyncGalleryEnqueuer. instance with the specified synchronization settings, connection, and file provider.

  @param settings A `SeafSyncSettings` object representing the synchronization settings.
  @param connection A `SeafConnection` object representing the connection to the Seafile server.
  @param fileProvider An object conforming to the `SeafSyncProviderProtocol` representing the file provider for synchronization.

  @return An initialized `SeafSyncGalleryEnqueuer` instance.
 */
- (id)init:(SeafSyncSettings *)settings connection:(SeafConnection *)connection andFileProvider:(id<SeafSyncProviderProtocol>) fileProvider;

@end

NS_ASSUME_NONNULL_END
