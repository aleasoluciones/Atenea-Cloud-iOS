/**
 * @file SeafSyncLogsService.m
 * @brief Implementation file for the SeafSyncLogsService class.
 *
 * This file contains the implementation of the SeafSyncLogsService class, which provides methods for checking and logging the upload status of files.
 */

#import "SeafSyncLogsService.h"
#import "SeafSyncLogRepository.h"
#import "SeafSyncCoreDataLogRepository.h"
#import "SeafDir.h"
#import "SeafSyncUtils.h"
#import "SeafSyncEnums.h"
#import "SeafConnection.h"
#import "SeafSyncItemProtocol.h"

@interface SeafSyncLogsService()

@property (nonatomic, strong) id<SeafSyncLogRepository> repository;
@property (nonatomic, strong) SeafConnection *connection;

@end

@implementation SeafSyncLogsService

/**
 * @brief Initializes the SeafSyncLogsService with the default SeafSyncCoreDataLogRepository.
 * @return An instance of SeafSyncLogsService.
 */
- (instancetype)initWithConnection:(SeafConnection *) connection {
    self = [super init];
    if (self) {
        self.repository = [[SeafSyncCoreDataLogRepository alloc] init];
        self.connection = connection;
    }
    return self;
}

/**
 * @brief Initializes the SeafSyncLogsService with a custom SeafSyncLogRepository implementation.
 * @param repository The custom SeafSyncLogRepository implementation to use.
 * @return An instance of SeafSyncLogsService.
 */
- (id)initWithRepository:(id<SeafSyncLogRepository>)repository andConnection:(SeafConnection *) connection  {
    self = [super init];
    if (self) {
        self.repository = repository;
        self.connection = connection;
    }
    return self;
}


/**
 * @brief Checks if a file was uploaded previously to the same target folder.
 * @param log The SeafSyncLog object representing the file to check.
 * @return YES if the file was already uploaded to the same target folder, otherwise NO.
 */
- (bool)isAlreadyLogged:(SeafSyncLog *)log {
 
    if (log) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncSettingId == %@ AND resourceId == %@", log.syncSettingId,log.resourceId];
        NSArray<SeafSyncLog *> *logs = [self.repository find:predicate];
        return [logs count] > 0;
    }
    return false;
}


/**
 * @brief Logs the upload status of a file.
 * @param log The SeafSyncLog object representing the file to log.
 * @return YES if the file was successfully logged, otherwise NO.
 */
- (bool)log:(SeafSyncLog *)log {
    if (log) {
        [self.repository insert:log];
        return true;
    }
    return false;
}



/**
 * @brief Updates the repository with the information from the provided sync log.
 *
 * This method takes a SeafSyncLog object and updates the repository with the information
 * contained in the log. If the provided log is nil, the method returns false, indicating
 * that no update was performed.
 *
 * @param log A SeafSyncLog object containing synchronization information.
 * @return Returns true if the update was successful, false if the provided log is nil.
 */
- (bool)update:(SeafSyncLog *)log {
    if (log) {
        [self.repository update:log];
        return true;
    }
    return false;
}




/**
 * @brief Clears all logs.
 */
- (void)clear {
    [self.repository clear];
}


/**
 * @brief Gets all logs.
 */
- (NSArray<SeafSyncLog *> *)all{
    return [self.repository all];
}

/**
 Get logs from setting
 */
- (NSArray<SeafSyncLog *> *)getLogsFromSetting:(SeafSyncSettings *) setting{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncSettingId == %@ ",setting.identifier];
    return [self.repository find:predicate];
}

/**
 Remove logs from setting
 */
- (void)removeFromSetting:(SeafSyncSettings *) setting{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncSettingId == %@ ",setting.identifier];
        [self.repository removeWith:predicate];
    });
}


@end

