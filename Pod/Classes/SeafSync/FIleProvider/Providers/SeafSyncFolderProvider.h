//
//  SeafSyncFolderProvider.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/9/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Represents a folder provider for Seafile synchronization.
 */
@interface SeafSyncFolderProvider : NSObject<SeafSyncProviderProtocol>

/**
 * @brief Initializes a new instance of the folder provider with the specified folder URL.
 *
 * @param folderURL The URL of the folder to be synchronized.
 * @return An initialized instance of the folder provider.
 */
- (id)initWithFolderURL:(NSURL *)folderURL;

/**
 * @brief Retrieves the list of files from the folder provider.
 *
 * @param onError An optional error parameter to capture any errors that occur during the operation.
 * @return An array of items conforming to the SeafSyncItemProtocol.
 */
- (NSMutableArray<id<SeafSyncItemProtocol>> *)getFiles:(NSError **)onError;

@end

NS_ASSUME_NONNULL_END
