/**
 * @file DefaultSeafSyncSettingsRepository.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the DefaultSeafSyncSettingsRepository class.
 *
 * This file contains the definition of the DefaultSeafSyncSettingsRepository class, which provides a default implementation of the SeafSyncSettingsRepository protocol.
 */

#import <UIKit/UIKit.h>
#import "SeafSyncSettingsRepository.h"

NS_ASSUME_NONNULL_BEGIN

@interface DefaultSeafSyncSettingsRepository : NSObject <SeafSyncSettingsRepository>

/**
 * Initializes a DefaultSeafSyncSettingsRepository with a storage key.
 *
 * @param key The key associated with the repository used for storage.
 * @return An instance of DefaultSeafSyncSettingsRepository.
 */
- (id)initWithStorageKey:(NSString *)key;

/**
 * Retrieves all SeafSyncSettings from the repository.
 *
 * @return An array containing all SeafSyncSettings stored in the repository.
 */
- (NSArray<SeafSyncSettings *> *)all;

/**
 * Retrieves filtered SeafSyncSettings from the repository.
 *
 * @return An array containing all SeafSyncSettings stored in the repository.
 */
- (NSArray<SeafSyncSettings *> *)filter:(NSPredicate *) predicate;

/**
 * Inserts a new SeafSyncSettings into the repository.
 *
 * @param setting The SeafSyncSettings to insert into the repository.
 */
- (void)insert:(SeafSyncSettings *)setting;

/**
 * Updates an existing SeafSyncSettings in the repository.
 *
 * @param setting The SeafSyncSettings to update in the repository.
 */
- (void)update:(SeafSyncSettings *)setting;

/**
 * Removes a SeafSyncSettings item from the repository.
 *
 * @param setting The SeafSyncSettings to remove from the repository.
 */
- (void)remove:(SeafSyncSettings *)setting;

/**
 * Removes all SeafSyncSettings items from the repository.
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END

