//
//  SeafSyncEnums.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 23/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// \file SeafSyncEnums.h
/// \brief This file defines several enumerations related to synchronization in Seafile.
///
/// \author Javier Godoy (javigodoy@meytel.net)

/// \enum SeafSyncType
/// \brief Defines the synchronization types.
///
/// Possible values:
/// - Folder: Read from local device storage
/// - Album: Reads from a single album
/// - Gallery: Reads from all the gallery
///
typedef NS_ENUM(NSInteger, SeafSyncType) {
    Folder,
    Album,
    Gallery
};

/// \enum SeafSyncMode
/// \brief Defines the synchronization modes.
///
/// Possible values:
/// - Full: Read all files
/// - Incremental: Read only files since the creation date
///
typedef NS_ENUM(NSInteger, SeafSyncMode) {
    Full,
    Incremental
};


/// \enum SeafSyncExpiration
/// \brief Defines the synchronization modes.
///
/// Possible values:
/// - Full: Read all files
/// - Incremental: Read only files since the creation date
///
typedef NS_ENUM(NSInteger, SeafSyncLifetimeType) {
    SeafSyncLifetimeTypeTemporal,
    SeafSyncLifetimeTypePermanent
};



/// \enum SeafSyncState
/// \brief Defines the synchronization states.
///
/// Possible values:
/// - Pending: Synchronization is pending
/// - Running: Synchronization is in progress
/// - Error: Synchronization encountered an error
/// - Expired: Synchronization has expired
/// - Completed: Synchronization is completed
///
typedef NS_ENUM(NSInteger, SeafSyncState) {
    SeafSyncStatePending,
    SeafSyncStateRunning,
    SeafSyncStateError,
    SeafSyncStateExpired,
    SeafSyncStateCompleted,
    SeafSyncStateUploading,
    SeafSyncStateCancelled,
    SeafSyncStateInactive,
};

/// \enum SyncTreeType
/// \brief Defines the types of synchronization tree elements.
///
/// Possible values:
/// - TreeRoot: The root of the synchronization tree
/// - TreeFolder: A folder in the synchronization tree
/// - TreeFile: A file in the synchronization tree
///
typedef NS_ENUM(NSInteger, SyncTreeType) {
    TreeRoot,
    TreeFolder,
    TreeFile
};

/// \enum SyncUploadFileState
/// \brief Defines the states of file upload in synchronization.
///
/// Possible values:
/// - SyncUploadFileStateUnknow: Unknown state
/// - SyncUploadFileStateInQueue: File is in the upload queue
/// - SyncUploadFileStateUploaded: File has been uploaded
/// - SyncUploadFileStateErrored: File upload encountered an error
///
typedef NS_ENUM(NSInteger, SyncUploadFileState) {
    SyncUploadFileStateUnknow,
    SyncUploadFileStateInQueue,
    SyncUploadFileStateUploaded,
    SyncUploadFileStateErrored
};

/// \enum SeafSyncNetworkState
/// \brief Defines the network states for synchronization.
///
/// Possible values:
/// - SeafSyncNetworkStateWifi: WiFi network is available
/// - SeafSyncNetworkState3G: 3G network is available
/// - SeafSyncNetworkStateUnknow: Network state is unknown
///
typedef NS_ENUM(NSInteger, SeafSyncNetworkState) {
    SeafSyncNetworkStateWifi,
    SeafSyncNetworkState3G,
    SeafSyncNetworkStateUnknow
};


typedef NS_ENUM(NSInteger, SeafSyncError) {
    SeafSyncErrorFolderNotFound,
    SeafSyncErrorTargetNotFound,
    SeafSyncErrorQuotaExceeded,
    SeafSyncErrorNoError
};

NS_ASSUME_NONNULL_END

