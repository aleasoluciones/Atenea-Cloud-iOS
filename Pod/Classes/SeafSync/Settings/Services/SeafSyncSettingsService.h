/**
 * @file SeafSyncSettingsService.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncSettingsService class.
 *
 * This file contains the interface for the SeafSyncSettingsService class, which provides a service for managing synchronization settings.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncSettings.h"
#import "SeafSyncSettingsRepository.h"
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncSettingsService
 * @brief A service for managing synchronization settings.
 */
@interface SeafSyncSettingsService : NSObject

/**
 * Initializes a SeafSyncSettingsService with default settings repository.
 *
 * @return An instance of SeafSyncSettingsService with a default settings repository.
 */
-(instancetype)initWithConnection:(SeafConnection *) connection;

/**
 * Initializes a SeafSyncSettingsService with a custom settings repository.
 *
 * @param repository The custom settings repository to use.
 * @return An instance of SeafSyncSettingsService with the provided settings repository.
 */
-(instancetype)initWith:(id<SeafSyncSettingsRepository>) repository andConnection:(SeafConnection *) connection;

/**
 * Retrieves all synchronization settings.
 *
 * @return An array containing all synchronization settings.
 */
- (NSArray<SeafSyncSettings *> *)getSettings;

/**
 * Retrieves all synchronization active settings.
 *
 * @return An array containing all active synchronization settings.
 */
- (NSArray<SeafSyncSettings *> *)activeSettings;

/**
 * Adds a synchronization setting to the service.
 *
 * @param setting The synchronization setting to add.
 */
- (void)add:(SeafSyncSettings *)setting;

/**
 * Removes a synchronization setting from the service.
 *
 * @param setting The synchronization setting to remove.
 */
- (void)remove:(SeafSyncSettings *)setting;

/**
 * Clears all synchronization settings from the service.
 */
- (void)clear;

/**
 * Retrieves all synchronization settings from the repository.
 *
 * @return An array containing all synchronization settings.
 */
- (NSArray<SeafSyncSettings *> *)all;

/**
 * Updates the state of a synchronization setting.
 *
 * @param setting The synchronization setting to update.
 * @param state The new state for the synchronization setting.
 */
- (void)updateState:(SeafSyncSettings *)setting to:(SeafSyncState)state;

/**
 * Sets the last run time for a synchronization setting.
 *
 * @param setting The synchronization setting for which to set the last run time.
 */
- (void)setLastRunTime:(SeafSyncSettings *)setting;


/**
 * Register an error for the specified SeafSyncSettings with the given error description.
 *
 * @param settings The SeafSyncSettings object to register the error for.
 * @param error The error to be registered.
 */
- (void)registerErrorIn:(SeafSyncSettings *)settings withError:(NSError *)error;

/**
 Finds and returns an array of SeafSyncSettings objects based on the specified predicate.

 This method searches for SeafSyncSettings objects in the collection that satisfy the given predicate.

 @param predicate The predicate to use for filtering the results.
 @return An array of SeafSyncSettings objects that match the specified predicate.

 @note The returned array may be empty if no matching objects are found.
 */
- (NSArray<SeafSyncSettings *> *)find:(NSPredicate *) predicate;


@end

NS_ASSUME_NONNULL_END

