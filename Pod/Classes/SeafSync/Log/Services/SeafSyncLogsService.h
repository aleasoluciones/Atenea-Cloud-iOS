/**
 * @file SeafSyncLogsService.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncLogsService class.
 *
 * This file declares the SeafSyncLogsService class, which provides methods for checking and logging the upload status of files.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncLogRepository.h"
#import "SeafSyncLog.h"
#import "SeafSyncEnums.h"
#import "SeafConnection.h"
#import "SeafSyncItemProtocol.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncLogsService
 * @brief The SeafSyncLogsService class provides methods for checking and logging the upload status of files.
 */
@interface SeafSyncLogsService : NSObject


- (instancetype)initWithConnection:(SeafConnection *) connection;

/**
 * @brief Initializes a new instance of SeafSyncLogsService with a custom SeafSyncLogRepository implementation.
 *
 * @param repository The custom SeafSyncLogRepository implementation.
 * @return An instance of SeafSyncLogsService.
 */
- (id)initWithRepository:(id<SeafSyncLogRepository>)repository andConnection:(SeafConnection *) connection;

/**
 * @brief Logs the upload status of a file.
 *
 * @param log The SeafSyncLog object representing the file to log.
 * @return YES if the file was successfully logged, otherwise NO.
 */
- (bool)log:(SeafSyncLog *)log;


/**
 Checks whether a sync log entry is already logged.

 This method determines whether a given sync log entry is already present in the log.

 @param log The sync log entry to check for existence.

 @return YES if the sync log entry is already present, NO otherwise.
 */
- (bool)isAlreadyLogged:(SeafSyncLog *)log ;

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
- (bool)update:(SeafSyncLog *)log;

/**
 * @brief Clears all logs.
 */
- (void)clear;


/**
 * @brief Gets all logs.
 */
- (NSArray<SeafSyncLog *> *)all;


/**
 Remove logs from setting
 * @param setting The SeafSyncSettings to remove logs from
 */
- (void)removeFromSetting:(SeafSyncSettings *) setting;


/**
 Get logs from setting
 * @param setting The SeafSyncSettings to gets logs from
 */
- (NSArray<SeafSyncLog *> *)getLogsFromSetting:(SeafSyncSettings *) setting;

@end

NS_ASSUME_NONNULL_END

