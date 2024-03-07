/**
 * @file SeafEnqueuerProtocol.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafEnqueuerProtocol protocol.
 *
 * This file declares the SeafEnqueuerProtocol protocol, which defines the methods required for a file uploader in the Seafile application.
 */

#import <Foundation/Foundation.h>
#import "SeafPhotoAsset.h"
#import "SeafUploadFile.h"
#import "SeafSyncSettings.h"
#import "SeafSyncLogsService.h"

NS_ASSUME_NONNULL_BEGIN


typedef void (^EnqueueCompletionBlock)(BOOL success);


/**
 * @protocol SeafEnqueuerProtocol
 * @brief The SeafEnqueuerProtocol protocol defines methods for a file uploader in the Seafile application.
 */
@protocol SeafEnqueuerProtocol

/**
 * @brief Initializes a new instance of the uploader with specified synchronization settings and connection.
 *
 * @param settings The SeafSyncSettings object representing the synchronization settings for the uploader.
 * @param connection The SeafConnection instance to be used for the upload.
 * @return An instance conforming to the SeafEnqueuerProtocol.
 */
- (id)init:(SeafSyncSettings *)settings connection:(SeafConnection *)connection;

/**
 * @brief Starts the upload process.
 *
 * This method initiates the file upload according to the implemented logic in the uploader.
 */
- (void)enqueue;


/**
 * Calculate the estimated upload size in bytes for the current sync operation.
 *
 * This method calculates the estimated upload size in bytes by summing up the sizes of all files
 * that have changed since the last synchronization in the specified source folder.
 *
 * @return The estimated upload size in bytes.
 */
-(long long) estimatedUploadSizeInBytes;




-(void) onEnqueueCompleted:(EnqueueCompletionBlock)handler;


@end

NS_ASSUME_NONNULL_END

