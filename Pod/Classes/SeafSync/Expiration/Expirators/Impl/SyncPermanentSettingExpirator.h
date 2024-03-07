/**
 * @file SyncPermanentSettingExpirator.h
 * @brief Declaration of SyncPermanentSettingExpirator class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncSettings.h"
#import "SyncSettingBaseExpirator.h"
#import "SeafSyncExpiratorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SyncPermanentSettingExpirator
 * @brief Expirator for handling permanent synchronization settings.
 *
 * The SyncPermanentSettingExpirator class is responsible for handling expiration logic
 * based on permanent synchronization settings. It inherits from SyncSettingBaseExpirator
 * and conforms to the SeafSyncExpiratorProtocol.
 */
@interface SyncPermanentSettingExpirator : SyncSettingBaseExpirator<SeafSyncExpiratorProtocol>

/**
 * @brief Initializes a new instance of the SyncPermanentSettingExpirator class with the specified settings.
 * @param setting The synchronization settings.
 * @return An initialized instance of SyncPermanentSettingExpirator.
 */
- (id)initWithSettings:(SeafSyncSettings *)setting;

/**
 * @brief Initiates the process of removing expired synchronization logs from the cloud repository.
 */
- (void)run;

@end

NS_ASSUME_NONNULL_END
