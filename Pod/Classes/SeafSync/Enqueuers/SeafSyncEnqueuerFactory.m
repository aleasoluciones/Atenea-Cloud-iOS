/**
 * @file SeafSyncEnqueuerFactory.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncEnqueuerFactory class.
 *
 * This file contains the implementation of the SeafSyncEnqueuerFactory class, which is responsible for creating instances of uploaders for synchronization in the Seafile application.
 */

#import "SeafSyncEnqueuerFactory.h"
#import "SeafSyncEnums.h"
#import "SeafSyncTreeEnqueuer.h"
#import "SeafSyncGalleryEnqueuer.h"

@implementation SeafSyncEnqueuerFactory

/**
 * @brief Creates and returns an instance of an uploader based on the specified connection and synchronization settings.
 *
 * @param connection The SeafConnection instance to be used for the upload.
 * @param settings The SeafSyncSettings object representing the synchronization settings for the uploader.
 * @return An instance conforming to the SeafEnqueuerProtocol for handling the upload.
 */
+ (id<SeafEnqueuerProtocol>)getEnqueuerFor:(SeafConnection *)connection settings:(SeafSyncSettings *)settings {
    
    switch (settings.sourceType) {
        case Folder:
            return [[SeafSyncTreeEnqueuer alloc] init:settings connection:connection];
            break;
            
        case Album:
        case Gallery:
            return [[SeafSyncGalleryEnqueuer alloc] init:settings connection:connection];
            break;
    }
}

@end

