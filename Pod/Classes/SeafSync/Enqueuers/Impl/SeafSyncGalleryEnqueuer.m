/**
 * @file SeafSyncGalleryEnqueuer.m
 * @brief Implementation of SeafSyncGalleryEnqueuer class.
 *
 * This file contains the implementation of the SeafSyncGalleryEnqueuer class,
 * which is responsible for synchronizing and uploading files from a gallery to a specified directory.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 2/10/23.
 */

#import "SeafSyncGalleryEnqueuer.h"
#import "SeafSyncSettings.h"
#import "SeafSyncUtils.h"
#import "SeafDir.h"
#import "SeafUploadFile.h"
#import "SeafConnection.h"
#import "SeafDataTaskManager.h"
#import "SeafSyncLogsService.h"
#import "SeafSyncProviderProtocol.h"
#import "SeafDataTaskManager.h"
#import "SeafSyncFileProviderFactory.h"
#import "SeafSyncItemProtocol.h"
#import "SeafSyncAssetItem.h"
#import "SeafEnqueueFileFactory.h"
#import "SeafSyncSettingsService.h"
#import "SeafSyncEnums.h"
#import "SeafSyncErrorLogger.h"
#import "SeafSyncLogUploadFileAdapter.h"



/**
 * @brief Private interface for SeafSyncGalleryEnqueuer.
 */
@interface SeafSyncGalleryEnqueuer ()

@property (nonatomic, retain) SeafSyncSettings *settings;
@property (nonatomic, retain) SeafConnection *connection;
@property (nonatomic, retain) SeafDir  *targetDirectory;
@property (nonatomic, retain) SeafSyncLogsService *logService;
@property (nonatomic, retain) id<SeafSyncProviderProtocol> fileProvider;
@property (nonatomic, retain) SeafSyncSettingsService *settingsService;
@property (nonatomic) EnqueueCompletionBlock completionBlock;


@end

/**
 * @implementation SeafSyncGalleryEnqueuer
 * @brief Synchronization and upload utility for gallery files.
 */
@implementation SeafSyncGalleryEnqueuer

/**
 * @brief Custom initializer for SeafSyncGalleryEnqueuer.
 *
 * @param settings The synchronization settings.
 * @param connection The connection object.
 * @return An instance of SeafSyncGalleryEnqueuer.
 */
- (id)init:(SeafSyncSettings *)settings connection:(SeafConnection *)connection {
    return [self init:settings connection:connection andFileProvider:[SeafSyncFileProviderFactory getProviderFor:settings]];
}


/**

  @brief Custom initializer for SeafSyncGalleryEnqueuer. instance with the specified synchronization settings, connection, and file provider.

  @param settings A `SeafSyncSettings` object representing the synchronization settings.
  @param connection A `SeafConnection` object representing the connection to the Seafile server.
  @param fileProvider An object conforming to the `SeafSyncProviderProtocol` representing the file provider for synchronization.

  @return An initialized `SeafSyncGalleryEnqueuer` instance.
 */
- (id)init:(SeafSyncSettings *)settings connection:(SeafConnection *)connection andFileProvider:(id<SeafSyncProviderProtocol>) fileProvider{
    self = [super init];
    if (self) {
        self.settings = settings;
        self.connection = connection;
        self.logService = [[SeafSyncLogsService alloc] initWithConnection:connection];
        self.settingsService = [[SeafSyncSettingsService alloc] initWithConnection:connection];
        self.fileProvider = fileProvider;
        
    }
    return self;
}

/**
 * @brief Loads the target folder and initiates the upload process.
 */
- (void)loadTargetFolder {
    SeafDir *dir = [[SeafDir alloc] initWithConnection:self.connection oid:@"" repoId:self.settings.repoId name:@"" path:self.settings.targetId mime:@""];
    
    [dir loadContentSuccess:^(SeafDir *dir) {
        self.targetDirectory = dir;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startUploadProcess];
        });
        
    } failure:^(SeafDir *dir, NSError *error) {
        [[SeafSyncErrorLogger sharedInstance] log:[[SeafSyncTargetNotFoundError alloc] init] inSetting:self.settings];
    }];
}

/**
 * @brief Main method for starting the synchronization process.
 */
- (void)enqueue {
    // Update state
    [self.settingsService updateState:self.settings to:SeafSyncStateRunning];
    [self loadTargetFolder];
}

/**
 * @brief Starts the upload process by iterating through files and adding them to the upload queue.
 */
- (void)startUploadProcess {
    
    NSError *error = nil;
    
    NSMutableArray<id<SeafSyncItemProtocol>> *items = [self.fileProvider getFiles:&error];
    
    if(error){
        // Update state and lastRunTime
        [[SeafSyncErrorLogger sharedInstance] log:[[SeafSyncSourceNotFoundError alloc] init] inSetting:self.settings];
        [self.settingsService setLastRunTime:self.settings];
        return;
    }
    
    [items enumerateObjectsUsingBlock:^(id<SeafSyncItemProtocol> _Nonnull syncItem, NSUInteger idx, BOOL * _Nonnull stop) {
        SeafUploadFile *uploadFile = [SeafEnqueueFileFactory createFrom:syncItem];
        uploadFile.udir = self.targetDirectory;
        uploadFile.syncId = self.settings.identifier;
        uploadFile.syncFileId = [syncItem identifier];
        uploadFile.filesize = syncItem.sizeInBytes;
        uploadFile.retryable = true;

        uploadFile.onlyWifi = self.settings.uploadOnlyOverWifi;
        [uploadFile setCompletionBlock:^(SeafUploadFile *file, NSString *oid, NSError *error) {
            if (error == nil) {
                [self.logService log:[[SeafSyncLogUploadFileAdapter alloc] initWith:file andOID:oid andAccount:self.connection.username]];
            }
        }];
        
        if (FALSE == [self wasUploadedOrQueued:uploadFile]) {
            [self addToUploadQueueTask:uploadFile];
        }
        
    }];
    
    
    // Update state if no previous errors
    if(self.settings.lastRunError == SeafSyncErrorNoError){
        [self.settingsService updateState:self.settings to:SeafSyncStateCompleted];
    }
    
    // Update lastRunTime
    [self.settingsService setLastRunTime:self.settings];
    
    
    //Notify
    if(self.completionBlock != nil){ self.completionBlock(TRUE); }
    
}

/**
 * @brief Adds a file to the upload queue task.
 *
 * @param fileToUpload The file to be added to the upload queue.
 */
- (void)addToUploadQueueTask:(SeafUploadFile *)fileToUpload {
    // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SeafDataTaskManager.sharedObject addUploadTask:fileToUpload];
    //});
}

/**
 * @brief Checks whether a file was already uploaded or queued for upload.
 *
 * @param uploadFile The file to check.
 * @return A boolean indicating whether the file was already uploaded or queued.
 */
- (BOOL)wasUploadedOrQueued:(SeafUploadFile *)uploadFile {
    return
    [self fileNamed:[[uploadFile name] lastPathComponent] alreadyExistsIn:uploadFile.udir];
}


/**
 * @brief Checks if a file with a specific name already exists in the target folder.
 *
 * @param fileName The name of the file.
 * @param targetFolder The target folder to check.
 * @return A boolean indicating whether the file already exists in the target folder.
 */
- (BOOL)fileNamed:(NSString *)fileName alreadyExistsIn:(SeafDir *)targetFolder {
    return [targetFolder nameExist:fileName];
}



/**
 * Calculate the estimated upload size in bytes for the current sync operation.
 *
 * This method calculates the estimated upload size in bytes by summing up the sizes of all files
 * that have changed since the last synchronization in the specified source folder.
 *
 * @return The estimated upload size in bytes.
 */
-(long long) estimatedUploadSizeInBytes{
    
    __block long long uploadSize = 0;
    
    NSMutableArray<id<SeafSyncItemProtocol>> *items = [self.fileProvider getFiles:nil];
    
    [items enumerateObjectsUsingBlock:^(id<SeafSyncItemProtocol> _Nonnull syncItem, NSUInteger idx, BOOL * _Nonnull stop) {
        uploadSize += [syncItem sizeInBytes];
    }];
    
    return uploadSize ;
}


- (void)onEnqueueCompleted:(EnqueueCompletionBlock) handler {
    self.completionBlock = handler;
}




@end

