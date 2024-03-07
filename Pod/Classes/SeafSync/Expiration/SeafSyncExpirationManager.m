/**
 * @file SeafSyncExpirationManager.m
 * @brief Implementation of SeafSyncExpirationManager class.
 *
 * This class manages the expiration of synchronization logs in Seafile.
 * It calculates the expiration date of logs based on the configured duration
 * and removes the expired logs from the cloud repository.
 *
 * @author apps meytel
 * @date 13/11/23
 */

#import "SeafSyncExpirationManager.h"
#import "SeafSyncLogsService.h"
#import "SeafSyncLog.h"
#import "SeafSyncUtils.h"
#import "Debug.h"
#import "ExtentedString.h"
#import "SeafSyncExpiratorFactory.h"
#import "SeafSyncronizer.h"

/**
 *  SeafSyncExpirationManager
 * @brief Manages the expiration of synchronization logs in Seafile.
 *
 * The SeafSyncExpirationManager class is responsible for calculating the expiration date
 * of synchronization logs based on the configured duration and removing the expired logs
 * from the cloud repository. It utilizes the SeafSyncExpiratorFactory to get the appropriate
 * expirator based on the provided settings.
 */
@interface SeafSyncExpirationManager()

@property (nonatomic) SeafSyncExpiratorFactory *expiratorFactory; ///< Factory for creating expirators.

@end

@implementation SeafSyncExpirationManager

// Static var for singleton
static SeafSyncExpirationManager *sharedInstance = nil;

/**
 * @brief Provides a shared instance of SeafSyncExpirationManager.
 * @return The shared instance of SeafSyncExpirationManager.
 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.expiratorFactory = [[SeafSyncExpiratorFactory alloc] init];
    });
    return sharedInstance;
}

/**
 * @brief Runs the expiration process based on the provided settings.
 * @param setting The synchronization settings used for expiration.
 */
- (void)run:(SeafSyncSettings *)setting {
    [[self.expiratorFactory getExpiratorFor:setting] run];
}

@end
