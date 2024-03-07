/**
 * @file SyncPermanentSettingExpirator.m
 * @brief Implementation of SyncPermanentSettingExpirator class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
 */

#import "SyncPermanentSettingExpirator.h"
#import "SeafSyncLogsService.h"
#import "SeafSyncLog.h"
#import "SeafSyncUtils.h"
#import "Debug.h"
#import "ExtentedString.h"

/**
 * SyncPermanentSettingExpirator
 * @brief Expirator for handling permanent synchronization settings.
 *
 * The SyncPermanentSettingExpirator class is responsible for handling expiration logic
 * based on permanent synchronization settings. It inherits from SyncSettingBaseExpirator
 * and conforms to the SeafSyncExpiratorProtocol.
 */
@interface SyncPermanentSettingExpirator()

@property (nonatomic, retain) SeafSyncSettings *setting; ///< The synchronization settings.
@property (nonatomic, retain) SeafSyncLogsService *logsService; ///< Service for managing synchronization logs.

@end

@implementation SyncPermanentSettingExpirator

/**
 * @brief Initializes a new instance of the SyncPermanentSettingExpirator class with the specified settings.
 * @param setting The synchronization settings.
 * @return An initialized instance of SyncPermanentSettingExpirator.
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
    // No expiration
    if (self.setting.durationOfBackupFilesOnCloudInDays == 0) {
        return;
    }
    
    // Retrieve a list of expired sync logs
    NSArray<SeafSyncLog *> *expiredLogs = [self getExpiredLogs];
    
    // Remove files from the cloud using the expired sync logs
    [expiredLogs enumerateObjectsUsingBlock:^(SeafSyncLog *log, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeFileFromCloudUsing:log];
    }];
}


/**
 * @brief Gets the list of synchronization logs that have expired.
 * @return An array of SeafSyncLog objects representing the expired logs.
 */
-(NSArray<SeafSyncLog * > *)getExpiredLogs{
    NSArray<SeafSyncLog *> *files = [self.logsService getLogsFromSetting:self.setting];
    
    return [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SeafSyncLog  *log, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        //If already uploaded do not check more
        if(log.expirationRanOn){
            return  false;
        }
        
        //Check if expiration date has come
        NSDate *fileExpirationDate = [self calculateExpirationDate:log];
        NSDate *today = [NSDate date];
        return ([SeafSyncUtils date:today isOlderThan:fileExpirationDate]);
    }]];
}



/**
 * @brief Calculates the expiration date for a given synchronization log.
 * @param log The synchronization log for which to calculate the expiration date.
 * @return The calculated expiration date.
 */
-(NSDate *) calculateExpirationDate:(SeafSyncLog *) log{
    NSTimeInterval daysInterval = self.setting.durationOfBackupFilesOnCloudInDays * 24 * 60 * 60;
    NSDate *fileExpirationDate = [log.uploadedDate dateByAddingTimeInterval:daysInterval];
    return fileExpirationDate;
}


@end
