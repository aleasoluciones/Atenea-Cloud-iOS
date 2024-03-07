
/**
 * @file SeafSyncLog.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncLog class.
 *
 * This file contains the implementation of the SeafSyncLog class, which represents synchronization log information in the Seafile application.
 */

#import "SeafSyncLog.h"
#import "SeafSyncEnums.h"

@implementation SeafSyncLog

/// MARK: Properties

/**
 * @brief The getter and setter for the accountId property.
 */
@synthesize accountId = _accountId;
/**
 * @brief The getter and setter for the resourceId property.
 */
@synthesize resourceId = _resourceId;

/**
 * @brief The getter and setter for the targetId property.
 */
@synthesize targetId = _targetId;

/**
 * @brief The getter and setter for the targetId property.
 */
@synthesize resourceHash = _resourceHash;

/**
 * @brief The getter and setter for the uploadedDate property.
 */
@synthesize uploadedDate = _uploadedDate;

/**
 * @brief The getter and setter for the state property
 */
@synthesize uploadState = _uploadState;

/**
 * @brief The getter and setter for the syncSettingId property
 */
@synthesize syncSettingId = _syncSettingId;

/**
 * @brief The remote Identifier
 */
@synthesize remoteIdentifier = _remoteIdentifier;

/**
 * @brief The remote Name
 */
@synthesize remoteName = _remoteName;

/**
 * @brief The remote Name
 */
@synthesize remotePath = _remotePath;

/**
 * @brief flag to check if the expiration  (detetion from repo) has been done
 */
@synthesize expirationRanOn = _expirationRanOn;
@end
