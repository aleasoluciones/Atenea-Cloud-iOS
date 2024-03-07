/**
 * @file SeafSyncTree.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncTree class.
 *
 * This file contains the declaration of the SeafSyncTree class, which represents a synchronized tree structure.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncEnums.h"
#import "SeafSyncTreeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncTree
 * @brief Represents a synchronized tree structure.
 *
 * The SeafSyncTree class represents a synchronized tree structure used in Seafile synchronization.
 * It conforms to the SeafSyncTreeProtocol and NSCopying protocols.
 */
@interface SeafSyncTree : NSObject<SeafSyncTreeProtocol, NSCopying>

@end

NS_ASSUME_NONNULL_END

