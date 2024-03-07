/**
 * @file SeafSyncExpiratorFactory.m
 * @brief Implementation of SeafSyncExpiratorFactory class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
 */

#import "SeafSyncExpiratorFactory.h"
#import "SyncTemporalSettingExpirator.h"
#import "SyncPermanentSettingExpirator.h"

@implementation SeafSyncExpiratorFactory

/**
 * @brief Gets the expirator for the given synchronization settings.
 * @param setting The synchronization settings for which to obtain the expirator.
 * @return An object conforming to the SeafSyncExpiratorProtocol.
 */
- (id<SeafSyncExpiratorProtocol>)getExpiratorFor:(SeafSyncSettings *)setting {
    
    if (setting.lifeTime == SeafSyncLifetimeTypePermanent) {
        return [[SyncPermanentSettingExpirator alloc] initWithSettings:setting];
    }
    
    // Temporal
    return [[SyncTemporalSettingExpirator alloc] initWithSettings:setting];
}

@end
