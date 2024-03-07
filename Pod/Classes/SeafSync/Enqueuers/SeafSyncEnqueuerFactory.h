/**
 * @file SeafSyncEnqueuerFactory.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncEnqueuerFactory class.
 *
 * This file declares the SeafSyncEnqueuerFactory class, which is responsible for creating instances of uploaders for synchronization in the Seafile application.
 */

#import <Foundation/Foundation.h>
#import "SeafEnqueuerProtocol.h"
#import "SeafConnection.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncEnqueuerFactory
 * @brief The SeafSyncEnqueuerFactory class is responsible for creating instances of uploaders for synchronization.
 */
@interface SeafSyncEnqueuerFactory : NSObject

/**
 * @brief Creates and returns an instance of an uploader based on the specified connection and synchronization settings.
 *
 * @param connection The SeafConnection instance to be used for the upload.
 * @param settings The SeafSyncSettings object representing the synchronization settings for the uploader.
 * @return An instance conforming to the SeafEnqueuerProtocol for handling the upload.
 */
+ (id<SeafEnqueuerProtocol>)getEnqueuerFor:(SeafConnection *)connection settings:(SeafSyncSettings *)settings;

@end

NS_ASSUME_NONNULL_END
