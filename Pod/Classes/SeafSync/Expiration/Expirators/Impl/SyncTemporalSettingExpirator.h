/**
 * @file SyncTemporalSettingExpirator.h
 * @brief Declaration of SyncTemporalSettingExpirator class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncExpiratorProtocol.h"
#import "SeafSyncSettings.h"
#import "SyncSettingBaseExpirator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SyncTemporalSettingExpirator
 * @brief Expirator for handling temporal synchronization settings.
 *
 * The SyncTemporalSettingExpirator class is responsible for handling expiration logic
 * based on temporal synchronization settings. It inherits from SyncSettingBaseExpirator
 * and conforms to the SeafSyncExpiratorProtocol.
 */
@interface SyncTemporalSettingExpirator : SyncSettingBaseExpirator<SeafSyncExpiratorProtocol>

/**
 * @brief Initializes the expirator with the given synchronization settings.
 * @param setting The synchronization settings for which to initialize the expirator.
 * @return An instance of SyncTemporalSettingExpirator.
 */
- (id)initWithSettings:(SeafSyncSettings *)setting;

/**
 * @brief Runs the expiration process based on the configured temporal settings.
 */
- (void)run;

@end

NS_ASSUME_NONNULL_END
