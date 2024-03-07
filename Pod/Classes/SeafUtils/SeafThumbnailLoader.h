//
//  SeafThumbnailLoader.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafThumbnailLoader
 * @brief A class for loading thumbnails for files in a Seafile repository.
 */
@interface SeafThumbnailLoader : NSObject

/**
 * Initializes a new instance of the SeafThumbnailLoader class.
 * @param connection The SeafConnection object associated with the loader.
 * @return An initialized SeafThumbnailLoader object.
 */
- (id)initWithConnection:(SeafConnection *)connection;

/**
 * Loads a thumbnail for a file in the specified repository and path.
 * @param repoId The ID of the repository.
 * @param path The path of the file in the repository.
 * @param size The desired size of the thumbnail.
 * @param onCompleted A block to be executed upon completion, providing the loaded UIImage.
 */
- (void)load:(NSString *)repoId
      andPath:(NSString *)path
      andSize:(long)size
  onCompleted:(void (^)(UIImage *image))onCompleted;

@end

NS_ASSUME_NONNULL_END
