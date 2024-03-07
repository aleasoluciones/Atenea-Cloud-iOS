/**
 * @file SeafSyncExpirationManager.h
 * @brief Declaration of SeafSyncExpirationManager class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 13/11/23.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncExpirationManager
 * @brief Manages the expiration of synchronization logs in Seafile.
 *
 * The SeafSyncExpirationManager class is responsible for calculating the expiration date
 * of synchronization logs based on the configured duration and removing the expired logs
 * from the cloud repository. It utilizes the SeafSyncExpiratorFactory to get the appropriate
 * expirator based on the provided settings.
 */
@interface SeafSyncExpirationManager : NSObject

/**
 * @brief Provides a shared instance of SeafSyncExpirationManager.
 * @return The shared instance of SeafSyncExpirationManager.
 */
+ (instancetype)sharedInstance;

/**
 * @brief Runs the expiration process based on the provided settings.
 * @param setting The synchronization settings used for expiration.
 */
- (void)run:(SeafSyncSettings *)setting;

@end

NS_ASSUME_NONNULL_END
