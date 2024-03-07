/**
 * @file SeafSyncLogRepository.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncLogRepository protocol.
 *
 * This file declares the SeafSyncLogRepository protocol, which defines methods for managing synchronization log entries in the Seafile application.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncLog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @protocol SeafSyncLogRepository
 * @brief The SeafSyncLogRepository protocol defines methods for managing synchronization log entries.
 */
@protocol SeafSyncLogRepository 

/**
 * @brief Returns all synchronization log entries.
 *
 * @return An array containing all synchronization log entries.
 */
- (NSMutableArray<SeafSyncLog *> *)all;

/**
 * @brief Inserts a new synchronization log entry.
 *
 * @param log The SeafSyncLog object representing the synchronization log entry to be inserted.
 */
- (void)insert:(SeafSyncLog *)log;

/**
 * @brief Updates an existing synchronization log entry.
 *
 * @param log The SeafSyncLog object representing the synchronization log entry to be updated.
 */
- (void)update:(SeafSyncLog *)log;

/**
 * @brief Removes an existing synchronization log entry.
 *
 * @param log The SeafSyncLog object representing the synchronization log entry to be removed.
 */
- (void)remove:(SeafSyncLog *)log;

/**
 * @brief Removes  existing synchronizations using predicate.
 *
 * @param predicate The NSPredicate object used to filter
 */
- (void)removeWith:(NSPredicate *)predicate;

/**
 * @brief Filters synchronization log entries based on a predicate.
 *
 * @param predicate The NSPredicate used for filtering log entries.
 * @return An array containing synchronization log entries that match the predicate.
 */
- (NSArray<SeafSyncLog *> *)find:(NSPredicate *)predicate;

/**
 * @brief Removes all existing synchronization log entries.
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
