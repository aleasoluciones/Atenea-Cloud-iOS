/**
 * @file SeafSyncTreeBuilder.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncTreeBuilder class.
 *
 * This file contains the declaration of the SeafSyncTreeBuilder class, which is used to build synchronized tree structures.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncTree.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncTreeBuilder : NSObject

/**
 * Initializes an instance of SeafSyncTreeBuilder.
 *
 * @param sourceURL The source URL for the tree structure.
 * @param settings The synchronization settings to use.
 * @return An instance of SeafSyncTreeBuilder.
 */
-(id)init:(NSURL *) sourceURL settings:(SeafSyncSettings *) settings;

/**
 * Builds a synchronized tree structure.
 *
 * @return A SeafSyncTree object representing the synchronized tree.
 */
-(SeafSyncTree *) build;

@end

NS_ASSUME_NONNULL_END
