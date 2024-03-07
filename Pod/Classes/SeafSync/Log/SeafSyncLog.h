
/**
 * @file SeafSyncLog.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncLog class.
 *
 * This file declares the SeafSyncLog class, which represents synchronization log information in the Seafile application.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncEnums.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncLog
 * @brief The SeafSyncLog class represents synchronization log information.
 */
@interface SeafSyncLog : NSObject


/**
 * @brief The identifier (e.g., folder Id or album Id) from where files must be loaded.
 */
@property id accountId;

/**
 * @brief The date of creation of this sync log.
 */
@property NSDate *uploadedDate;

/**
 * @brief The identifier (e.g., folder Id or album Id) from where files must be loaded.
 */
@property id resourceId;

/**
 * @brief The folderId in the user's cloud where files are synchronized to.
 */
@property NSString *targetId;

/**
 * @brief The resourceHash in local file system
 */
@property NSString *resourceHash;

/**
 * @brief The SeafSyncSettings Id
 */
@property NSString *syncSettingId;

/**
 * @brief The resourceHash in local file system
 */
@property SyncUploadFileState uploadState;

/**
 * @brief The file remoteIdentifier
 */
@property NSString *remoteIdentifier;


/**
 * @brief The file remoteName
 */
@property NSString *remoteName;


/**
 * @brief The file remotePath
 */
@property NSString *remotePath;

/**
 * @brief flag to check if the expiration  (detetion from repo) has been done
 */
@property NSDate *expirationRanOn;

@end

NS_ASSUME_NONNULL_END

