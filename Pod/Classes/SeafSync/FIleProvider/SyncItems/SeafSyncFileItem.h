//
//  SeafSyncFileItem.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Represents a file item for Seafile synchronization.
 */
@interface SeafSyncFileItem : NSObject<SeafSyncItemProtocol>

/**
 * @brief Initializes a new instance of the file item with the specified file URL.
 *
 * @param url The URL of the file to be represented by the item.
 * @return An initialized instance of the file item.
 */
-(id)initWithPath:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
