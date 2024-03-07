//
//  SeafSyncTreeFolderStateRepository.h
//  Pods
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 20/9/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncTreeState.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @protocol SeafSyncTreeFolderStateRepository
 * @brief The SeafSyncTreeFolderStateRepository protocol defines methods for managing synchronization tree states.
 */
@protocol SeafSyncTreeFolderStateRepository

/**
 * Retrieves all synchronization tree states.
 * @return An array of SeafSyncTreeState objects representing all synchronization tree states.
 */
- (NSMutableArray<SeafSyncTreeState *> *)all;

/**
 * Inserts a new synchronization tree state.
 * @param state The SeafSyncTreeState object to insert.
 */
- (void)insert:(SeafSyncTreeState *)state;

/**
 * Updates an existing synchronization tree state.
 * @param state The SeafSyncTreeState object to update.
 */
- (void)update:(SeafSyncTreeState *)state;

/**
 * Removes an existing synchronization tree state.
 * @param state The SeafSyncTreeState object to remove.
 */
- (void)remove:(SeafSyncTreeState *)state;

/**
 * Filters synchronization tree states based on a predicate.
 * @param predicate The NSPredicate to filter results.
 * @return An array of SeafSyncTreeState objects that match the predicate.
 */
- (NSArray<SeafSyncTreeState *> *)find:(NSPredicate *)predicate;

/**
 * Removes all existing synchronization tree states.
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
