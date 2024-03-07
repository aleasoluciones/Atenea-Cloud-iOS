//
//  SeafSyncFolderStateService.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 25/9/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncTreeState.h"
#import "SeafSyncTreeFolderStateRepository.h"
#import "SeafSyncTree.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncFolderStateService
 * @brief The SeafSyncFolderStateService class provides methods for managing synchronization folder states.
 */
@interface SeafSyncFolderStateService : NSObject

//MARK: CRUD Methods

/**
 * Inserts a new synchronization tree state.
 * @param state The SeafSyncTreeState object to insert.
 */
-(void)insert:(SeafSyncTreeState *)state;

/**
 * Updates an existing synchronization tree state.
 * @param state The SeafSyncTreeState object to update.
 */
-(void)update:(SeafSyncTreeState *)state;

/**
 * Removes an existing synchronization tree state.
 * @param state The SeafSyncTreeState object to remove.
 */
-(void)remove:(SeafSyncTreeState *)state;

/**
 * Retrieves all synchronization tree states.
 * @return An array of SeafSyncTreeState objects representing all synchronization tree states.
 */
-(NSMutableArray<SeafSyncTreeState *> *)all;

/**
 * Removes all existing synchronization tree states.
 */
-(void)clear;

//MARK: Find Methods

/**
 * Finds synchronization tree states by URL.
 * @param url The URL to filter results.
 * @return An array of SeafSyncTreeState objects that match the URL.
 */
-(NSArray<SeafSyncTreeState *> *)findByURL:(NSURL *)url;

/**
 * Finds synchronization tree states by sync setting ID.
 * @param syncSettingId The sync setting ID to filter results.
 * @return An array of SeafSyncTreeState objects that match the sync setting ID.
 */
-(NSArray<SeafSyncTreeState *> *)findBySyncSetting:(NSString *)syncSettingId;

/**
 * Filters synchronization tree states based on a predicate.
 * @param predicate The NSPredicate to filter results.
 * @return An array of SeafSyncTreeState objects that match the predicate.
 */
-(NSArray<SeafSyncTreeState *> *)find:(NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END
