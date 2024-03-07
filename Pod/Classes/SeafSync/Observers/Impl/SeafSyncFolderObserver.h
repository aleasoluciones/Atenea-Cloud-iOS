/**
 * @file SeafSyncFolderObserver.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncFolderObserver class.
 *
 * This file declares the SeafSyncFolderObserver class, which is responsible for observing changes in a folder and invoking a callback when changes occur.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @typedef SeafSyncFolderObserverCallback
 * @brief A block type for the callback function when changes occur in the observed folder.
 * @param id any object.
 */




/**
 * @class SeafSyncFolderObserver
 * @brief The SeafSyncFolderObserver class is responsible for observing changes in a folder and invoking a callback when changes occur.
 */
@interface SeafSyncFolderObserver : NSObject



-(id) initWith:(NSURL *) urlFolderToObserve;


/**
 * @brief Starts observing a folder at the specified path and sets a callback function to be called when changes occur.
 *
 * @param callback The callback function to invoke when changes occur.
 */
- (void)start:(nullable SeafSyncObserverProtocolCallback)callback;

/**
 * @brief Stops observing the folder.
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END

