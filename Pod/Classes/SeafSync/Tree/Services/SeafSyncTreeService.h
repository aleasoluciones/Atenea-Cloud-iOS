/**
 * @file SeafSyncTreeService.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncTreeService class.
 *
 * This file contains the declarations for the SeafSyncTreeService class, which manages synchronization trees.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncTree.h"
#import "SeafSyncFolderStateService.h"
#import "SeafSyncTreeChangeDetector.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncTreeService : NSObject


/**
 * Builds a synchronization tree from a URL and settings.
 *
 * @param url The URL for the tree structure.
 * @param settings The synchronization settings to use.
 * @return A SeafSyncTree object representing the synchronization tree.
 */
-(SeafSyncTree *)buildFrom:(NSURL *) url settings:(SeafSyncSettings *) settings;

/**
 * Saves a synchronization tree.
 *
 * @param tree The synchronization tree to save.
 */
-(void) saveTree:(SeafSyncTree *) tree;

/**
 * Gets the changes in a synchronization tree since the last synchronization.
 *
 * @param tree The synchronization tree to check for changes.
 * @return A SeafSyncTree object representing the changes since the last synchronization.
 */
-(SeafSyncTree *) changesSinceLastSyncFor:(SeafSyncTree *) tree;

@end

NS_ASSUME_NONNULL_END

