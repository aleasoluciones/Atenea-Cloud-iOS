/**
 * @file SeafSyncSettingsRepository.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncSettingsRepository protocol.
 *
 * This file contains the definition of the SeafSyncSettingsRepository protocol, which is used for managing synchronization settings.
 */

#import <Foundation/Foundation.h>
#import "SeafPhotoAsset.h"
#import "SeafUploadFile.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SeafSyncSettingsRepository 

/**
 * Retrieves all synchronization settings.
 * @return An array containing all synchronization settings.
 */
- (NSArray<SeafSyncSettings *> *)all;


/**
 * Retrieves filtered synchronization settings.
 * @return An array containing all synchronization settings.
 */
- (NSArray<SeafSyncSettings *> *)filter:(NSPredicate *) predicate;


/**
 * Inserts a new synchronization setting.
 * @param setting The synchronization setting to insert.
 */
- (void)insert:(SeafSyncSettings *)setting;

/**
 * Updates an existing synchronization setting.
 * @param setting The synchronization setting to update.
 */
- (void)update:(SeafSyncSettings *)setting;

/**
 * Removes an existing synchronization setting.
 * @param setting The synchronization setting to remove.
 */
- (void)remove:(SeafSyncSettings *)setting;

/**
 * Removes all existing synchronization settings.
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END

