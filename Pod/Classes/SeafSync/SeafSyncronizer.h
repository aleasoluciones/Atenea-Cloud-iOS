/**
 * @file SeafSyncronizer.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncronizer class.
 *
 * This file declares the SeafSyncronizer class, which serves as a central synchronization manager.
 */

#import <Foundation/Foundation.h>
#import "SeafConnection.h"
#import "SeafSyncSettingsService.h"
#import "SeafSyncNetworkerService.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncronizer
 * @brief The SeafSyncronizer class serves as a central synchronization manager.
 */
@interface SeafSyncronizer : NSObject<SeafSyncNetworkerServiceObserverDelegate>

+(NSArray<SeafSyncronizer *> *)allInstances;

+(instancetype)sharedInstanceFor:(SeafConnection *)connection;

/**
 * @brief Initializes a new instance of SeafSyncronizer with a SeafConnection instance and the default SeafSyncSettingsService implementation.
 *
 * @param connection The SeafConnection instance to be used for synchronization.
 * @return An instance of SeafSyncronizer.
 */
- (id)initWithConnection:(SeafConnection *)connection;

/**
 * @brief Initializes a new instance of SeafSyncronizer with a SeafConnection instance and a custom SeafSyncSettingsService.
 *
 * @param connection The SeafConnection instance to be used for synchronization.
 * @param settingsService The custom SeafSyncSettingsService to manage synchronization settings.
 * @return An instance of SeafSyncronizer.
 */
- (id)initWithConnection:(SeafConnection *)connection settingsService:(SeafSyncSettingsService *)settingsService;

/**
 * @brief Starts synchronization for all configured settings.
 */
- (void)sync;

/**
 * @brief Starts synchronization for a specific synchronization setting.
 *
 * @param setting The SeafSyncSettings object representing the synchronization settings.
 */
- (void)startSyncForSetting:(SeafSyncSettings *)setting;

/**
 * @brief Adds a new synchronization setting.
 *
 * @param settings The SeafSyncSettings object representing the synchronization settings to be added.
 */
- (void)add:(SeafSyncSettings *)settings;

/**
 * @brief Removes a synchronization setting.
 *
 * @param settings The SeafSyncSettings object representing the synchronization settings to be removed.
 */
- (void)remove:(SeafSyncSettings *)settings;


/**
 * @brief Gets all settings in this syncronizer
 * @return An array of SeafSyncSettings.
 */
- (NSArray<SeafSyncSettings * > *)settings;

/**
 * @brief Returns the current SeafConnection for this syncronizer
 *
 * @return An instance of SeafConnection.
 */
- (SeafConnection *)getConnectionInUse;


/**
 Notifies errors if needed.

 This method checks for errors and notifies if any errors are present.
*/
-(void) notifyErrorsIfNeeded;


@end

NS_ASSUME_NONNULL_END

