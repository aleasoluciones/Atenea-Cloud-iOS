/**
 * @file SeafSyncTreeEnqueuer.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncTreeEnqueuer class.
 *
 * This file declares the SeafSyncTreeEnqueuer class, which implements the SeafEnqueuerProtocol for synchronizing files in a tree structure.
 */

#import <Foundation/Foundation.h>
#import "SeafEnqueuerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncTreeEnqueuer
 * @brief The SeafSyncTreeEnqueuer class implements the SeafEnqueuerProtocol for synchronizing files in a tree structure.
 */
@interface SeafSyncTreeEnqueuer : NSObject<SeafEnqueuerProtocol>

@end

NS_ASSUME_NONNULL_END
