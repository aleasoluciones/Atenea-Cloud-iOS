/**
 * @file SeafSyncSettings.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncSettings class.
 *
 * This file declares the SeafSyncSettings class, which represents synchronization settings
 * for syncing files from a source folder to a target folder in the user's cloud storage.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncEnums.h"
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncSettings
 * @brief The SeafSyncSettings class represents synchronization settings for syncing files
 * from a source folder to a target folder in the user's cloud storage.
 */
@interface SeafSyncSettings : NSObject <NSCoding>


/**
 * A flag indicating whether setting is active or not
 */
@property bool active;


/**
 * The unique identifier associated with the user account.
 */
@property NSString *accountId;

/**
 * The identifier of the sync settings.
 */
@property id identifier;

/**
 * The date when the sync settings were created.
 */
@property NSDate *creationDate;

/**
 * The date until which the sync settings are available.
 */
@property NSDate *availableUntilDate;


/**
 * The duration date for make available files on cloud
 */
@property NSInteger durationOfBackupFilesOnCloudInDays;


/**
 * The identifier of the resource.
 */
@property id resourceId;

/**
 * The identifier of the target folder.
 */
@property NSString *targetId;

/**
 * The identifier of the repository.
 */
@property NSString *repoId;

/**
 * The type of the source for synchronization.
 */
@property SeafSyncType sourceType;

/**
 * The synchronization mode (Full / Incremental)
 */
@property SeafSyncMode mode;

/**
 * The synchronization lifetime mode (Permanent / Temporal)
 */
@property SeafSyncLifetimeType lifeTime;


/**
 * The date and time of the last synchronization run.
 */
@property NSDate *lastRunTime;

/**
 * The current state of synchronization.
 */
@property (nonatomic) SeafSyncState state;

/**
 * A flag indicating whether to upload files only over Wi-Fi.
 */
@property bool uploadOnlyOverWifi;

/**
 * A flag indicating whether to upload videos during synchronization.
 */
@property bool uploadVideos;

/**
 * The connection associated with the synchronization settings.
 */
@property SeafConnection *connection;

/**
 * The last error that occurred during a synchronization run.
 */
@property SeafSyncError lastRunError;


/**
 * The source URL.
 */
@property NSString *fullSourceURL;


/**
 * A flag indicating if files must be removed from cloud when this setting expires
 */
@property bool deleteFilesOnExpire;

@end

NS_ASSUME_NONNULL_END
