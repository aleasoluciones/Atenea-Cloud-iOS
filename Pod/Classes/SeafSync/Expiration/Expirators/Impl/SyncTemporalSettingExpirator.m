/**
 * @file SyncTemporalSettingExpirator.m
 * @brief Implementation of SyncTemporalSettingExpirator class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
 */

#import "SyncTemporalSettingExpirator.h"
#import "SeafSyncLogsService.h"
#import "SeafSyncLog.h"
#import "SeafSyncUtils.h"
#import "Debug.h"
#import "ExtentedString.h"

/**
 * SyncTemporalSettingExpirator
 * @brief Expirator for handling temporal synchronization settings.
 *
 * The SyncTemporalSettingExpirator class is responsible for handling expiration logic
 * based on temporal synchronization settings. It inherits from SyncSettingBaseExpirator
 * and conforms to the SeafSyncExpiratorProtocol.
 */
@interface SyncTemporalSettingExpirator()

@property (nonatomic, retain) SeafSyncSettings *setting; ///< The synchronization settings.
@property (nonatomic, retain) SeafSyncLogsService *logsService; ///< Service for managing synchronization logs.

@end

@implementation SyncTemporalSettingExpirator

/**
 * @brief Initializes a new instance of the SyncTemporalSettingExpirator class with the specified settings.
 * @param setting The synchronization settings.
 * @return An initialized instance of SyncTemporalSettingExpirator.
 */
- (id)initWithSettings:(SeafSyncSettings *)setting {
    self = [super initWithSettings:setting];
    if (self) {
        self.setting = setting;
        self.logsService = [[SeafSyncLogsService alloc] initWithConnection:self.setting.connection];
    }
    return self;
}

/**
 * @brief Initiates the process of removing expired synchronization logs from the cloud repository.
 */
- (void)run {
    
    if([self settingHasExpired] && self.setting.deleteFilesOnExpire == TRUE){
        // Retrieve a list of expired sync logs
        NSArray<SeafSyncLog *> *expiredLogs = [self getExpiredLogs];
        
        // Remove files from the cloud using the expired sync logs
        [expiredLogs enumerateObjectsUsingBlock:^(SeafSyncLog *log, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeFileFromCloudUsing:log];
        }];
        
    }
}

/**
 * @brief Checks if the synchronization setting has expired.
 * @return A boolean indicating whether the synchronization setting has expired.
 */
- (BOOL)settingHasExpired {
    NSDate *today = [NSDate date];
    
    if ([SeafSyncUtils date:self.setting.availableUntilDate isPreviousThan:today]) {
        return true;
    }
    
    return false;
}



/**
 * @brief Gets the list of synchronization logs that have expired.
 * @return An array of SeafSyncLog objects representing the expired logs.
 */
-(NSArray<SeafSyncLog * > *)getExpiredLogs{
    NSArray<SeafSyncLog *> *files = [self.logsService getLogsFromSetting:self.setting];
    
    return [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SeafSyncLog  *log, NSDictionary<NSString *,id> * _Nullable bindings) {
        //If log has an expiration date means file was expired previously
        return log.expirationRanOn == nil;
    }]];
    
}



@end
