
/**
 * @file SeafSyncTreeEnqueuer.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief This file contains the implementation of the SeafSyncTreeEnqueuer class.
 */

#import "SeafSyncTreeEnqueuer.h"
#import "SeafSyncTree.h"
#import "SeafSyncSettings.h"
#import "SeafSyncTreeService.h"
#import "SeafSyncUtils.h"
#import "SeafDir.h"
#import "SeafRepos.h"
#import "SeafUploadFile.h"
#import "SeafConnection.h"
#import "SeafDataTaskManager.h"
#import "SeafSyncLogsService.h"
#import "SeafEnqueueFileFactory.h"
#import "SeafSyncSettingsService.h"
#import "SeafSyncEnums.h"
#import "SeafQuotaSupervisor.h"
#import "SeafSyncErrorLogger.h"
#import "SeafSyncLogUploadFileAdapter.h"

// A block type for a callback when a SeafDir (directory) is created
typedef void (^SeafSyncSeafDirCreatedCallback)(SeafDir *directory);

/**
 * SeafSyncTreeEnqueuer
 * @brief The SeafSyncTreeEnqueuer class manages the synchronization of local file system trees with remote directories.
 */
@interface SeafSyncTreeEnqueuer ()

@property (nonatomic, retain) SeafSyncSettings *settings;
@property (nonatomic, retain) SeafSyncTreeService *treeService;
@property (nonatomic, retain) SeafSyncSettingsService *settingsService;
@property (nonatomic, retain) SeafConnection *connection;
@property (nonatomic, retain) SeafDir  *targetDirectory;
@property (nonatomic, retain) SeafSyncLogsService *logService;
@property (nonatomic, retain) dispatch_semaphore_t main_semaphore;
@property (nonatomic, retain) dispatch_queue_t creatorQueue;
@property (nonatomic, retain) NSMutableArray *foldersQueueControl;
@property (nonatomic, retain) NSMutableArray *foldersCreatedControl;
@property (nonatomic, retain) SeafQuotaSupervisor *quotaSupervisor;
@property (nonatomic) EnqueueCompletionBlock completionBlock;
@end

@implementation SeafSyncTreeEnqueuer

/**
 * Custom initializer for SeafSyncTreeEnqueuer.
 *
 * @param settings The synchronization settings.
 * @param connection The connection object.
 * @return An instance of SeafSyncTreeEnqueuer.
 */
- (id)init:(SeafSyncSettings *)settings connection:(SeafConnection *)connection {
    self = [super init];
    if (self) {
        self.settings = settings;
        self.connection = connection;
        
        self.treeService = [[SeafSyncTreeService alloc] init];
        self.logService = [[SeafSyncLogsService alloc] initWithConnection:connection];
        self.settingsService = [[SeafSyncSettingsService alloc] initWithConnection:connection];
        self.quotaSupervisor =  [SeafQuotaSupervisor sharedInstanceFor:connection];
        
        self.main_semaphore = dispatch_semaphore_create(0);
        
        self.creatorQueue = dispatch_queue_create("com.seafile.CreatorQueue", DISPATCH_QUEUE_SERIAL);
        self.foldersQueueControl = [[NSMutableArray alloc] initWithCapacity:0];
        self.foldersCreatedControl = [[NSMutableArray alloc] initWithCapacity:0];
        
    }
    return self;
}




/**
 * Load the target folder and initiate the synchronization process.
 */
- (void)loadTargetFolder {
    
    NSLog(@"SYNC: loading target folder %@",self.settings.identifier);
    
    
    SeafDir *dir = [[SeafDir alloc] initWithConnection:self.connection
                                                   oid:@""
                                                repoId:self.settings.repoId
                                                  name:@""
                                                  path:self.settings.targetId
                                                  mime:@""];
    
    [dir loadContentSuccess:^(SeafDir *dir) {
        self.targetDirectory = dir;
        [self startUploadProcess];
    } failure:^(SeafDir *dir, NSError *error) {
        // Update state to error
        [[SeafSyncErrorLogger sharedInstance] log:[[SeafSyncTargetNotFoundError alloc] init] inSetting:self.settings];
         
        dispatch_semaphore_signal(self.main_semaphore);
    }];
}

/**
 * Start the asynchronous upload process.
 */
- (void)startUploadProcess {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Check source folder URL because could be deleted from device
        NSURL *sourceFolderURL = [SeafSyncUtils urlFromBookmark:self.settings.resourceId];
        if(sourceFolderURL){
            
            // Build the current file system tree and the last synchronized tree
            SeafSyncTree *currentTree = [self.treeService buildFrom:sourceFolderURL  settings:self.settings];
            SeafSyncTree *treeWithChangesSinceLastSync = [self.treeService changesSinceLastSyncFor:currentTree];
            
            [self setFoldersQueueControlFromTree:treeWithChangesSinceLastSync];
            
            // If there are changes since the last sync, create remote directories
            if (treeWithChangesSinceLastSync) {
                [self createRemoteDirectories:treeWithChangesSinceLastSync remoteDirectory:self.targetDirectory];
                dispatch_semaphore_wait(self.main_semaphore, DISPATCH_TIME_FOREVER);
            }
            
            // Save the current tree folder state for this individual tree node
            [self.treeService saveTree:currentTree];
            
            // Update state if no previous errors
            if(self.settings.lastRunError == SeafSyncErrorNoError){
                [self.settingsService updateState:self.settings to:SeafSyncStateCompleted];
            }
            
            //Update last run time
            [self.settingsService setLastRunTime:self.settings];
            
            //Notify
            if(self.completionBlock != nil){ self.completionBlock(TRUE); }

        }
        else{
            //Else if sourceFolderURL is nil
            [[SeafSyncErrorLogger sharedInstance] log:[[SeafSyncSourceNotFoundError alloc] init] inSetting:self.settings];
            [self.settingsService setLastRunTime:self.settings];
            
            //Notify
            if(self.completionBlock != nil){ self.completionBlock(FALSE); }

        }
    });
}

/**
 * Main method for starting the synchronization process.
 */
- (void)enqueue {
    // Update state
    [self.settingsService updateState:self.settings to:SeafSyncStateRunning];
    
    [self loadTargetFolder];
}

/**
 * Set the folders queue control from the provided tree.
 *
 * @param treeWithChangesSinceLastSync The tree containing changes since the last synchronization.
 */
- (void)setFoldersQueueControlFromTree:(SeafSyncTree *)treeWithChangesSinceLastSync {
    self.foldersQueueControl = (NSMutableArray<id<SeafSyncTreeProtocol>> *)[treeWithChangesSinceLastSync getAllChildrensOfType:TreeFolder];
}

/**
 * Add a created folder to the control list.
 *
 * @param createdFolder The folder to add to the control list.
 */
- (void)addfoldersCreatedControl:(SeafDir *)createdFolder {
    [self.foldersCreatedControl addObject:createdFolder];
    // If all folders are checked, open the semaphore
    if ([self.foldersCreatedControl count] == [self.foldersQueueControl count]) {
        dispatch_semaphore_signal(self.main_semaphore);
    }
}


/**
 * Create remote directories for synchronization based on changes in the tree.
 *
 * This function calls to addFileToQueueFrom, who calls to addFileToQueueFrom recursively for subdirectories
 *
 * @param tree The tree containing changes.
 */
- (void)createRemoteDirectories:(SeafSyncTree *)tree  remoteDirectory:(SeafDir *)remoteDirectory  {
    

    __block SeafDir *targetRemoteDirectory = remoteDirectory;
    
    //Force load content to get fresh items
    [targetRemoteDirectory loadContentSuccess:^(SeafDir *dir) {
        
        //Overwrite targetRemoteDirectory with fresh data
        targetRemoteDirectory = dir;
        
        
        
        //Add own files to queue
        [self addFilesToQueueFrom:tree intoDirectory:targetRemoteDirectory];
        
        
        // Get direct children of type TreeFolder
        NSArray<SeafSyncTree *> *childFolders = (NSArray<SeafSyncTree *> *)[tree getChildrensOfType:TreeFolder];
        
        
        //We are processing ROOT object
        if([tree getType] == TreeRoot){
            //If no childrens, open semaphore and go out!
            if([childFolders count] == 0){
                dispatch_semaphore_signal(self.main_semaphore);
                return;
            }
        }
        
        for (SeafSyncTree *treeFolder in childFolders) {
            __block NSString *directoryName =  [[treeFolder getURL] lastPathComponent];
            
            // If the directory does not exist remotely we need to create it
            if (false == [targetRemoteDirectory nameExist:directoryName]) {
                [self createRemoteDirectoryInto:targetRemoteDirectory withName:directoryName onSuccess:^(SeafDir *directory) {
                    [self processChildDirectoryFrom:directory withName:directoryName fromTree:treeFolder];
                    
                }];
            } else {
                [self processChildDirectoryFrom:targetRemoteDirectory withName:directoryName fromTree:treeFolder];
            }
        }
        
        
    } failure:^(SeafDir *dir, NSError *error) {
        NSLog(@"Error loading dir content");
    }];
    
}

/**
 * Process a child directory from the specified directory and continue synchronization.
 *
 * @param directory The parent directory to process.
 * @param directoryName The name of the child directory.
 * @param tree The source tree folder.
 */
- (void)processChildDirectoryFrom:(SeafDir *)directory withName:(NSString *)directoryName fromTree:(SeafSyncTree *)tree {
    SeafDir *createdDirectory = [self findSubdirectoryIn:directory withName:directoryName];
    if (createdDirectory) {
        [createdDirectory loadContentSuccess:^(SeafDir *freshDirectory) {
            
            // Add files to the upload queue from the fresh directory
            [self addFilesToQueueFrom:tree intoDirectory:freshDirectory];
            
            // Add the freshly created directory to the control list
            [self addfoldersCreatedControl:freshDirectory];
            
            // Save the state of the tree
            [self.treeService saveTree:tree];
            
            // Create remote directories for the child directory
            [self createRemoteDirectories:tree remoteDirectory:freshDirectory];
            
        } failure:^(SeafDir *dir, NSError *error) {
            NSLog(@"Error loading directory data in %s", __PRETTY_FUNCTION__);
        }];
    }
}



/**
 * Create a remote directory and invoke a callback upon success.
 *
 * @param targetDirectory The parent directory where the new directory will be created.
 * @param name The name of the new directory.
 * @param callback The callback to be executed upon successful directory creation.
 */
- (void)createRemoteDirectoryInto:(SeafDir *)targetDirectory withName:(NSString *)name onSuccess: (SeafSyncSeafDirCreatedCallback)callback {
    [targetDirectory mkdir:name success:^(SeafDir *dir) {
        callback(dir);
    } failure:^(SeafDir *dir, NSError *error) {
        NSLog(@"Error creating directory in %s",__PRETTY_FUNCTION__);
        callback(nil);
    }];
}

/**
 * Add files from a tree folder to the upload queue.
 *
 * @param treeFolder The source tree folder.
 * @param directory The destination remote directory.
 */
- (void)addFilesToQueueFrom:(SeafSyncTree *)treeFolder intoDirectory:(SeafDir *)directory  {
    if (directory) {
        //Add files to Upload Queue
        [self addFilesInDirectoryToUploadQueue:directory from:treeFolder];
    }
}

/**
 * Add files from a tree folder to the upload queue.
 *
 * @param remoteDirectory The destination remote directory.
 * @param treeFolder The source tree folder.
 */
- (void)addFilesInDirectoryToUploadQueue:(SeafDir *)remoteDirectory from:(SeafSyncTree *)treeFolder {
    
    NSLog(@"SYNC: addFilesInDirectoryToUploadQueue %@",self.settings.identifier);
    
    
    NSArray *filesInFolder = [treeFolder getChildrensOfType:TreeFile];
    for (SeafSyncTree *file in filesInFolder) {
        
        if([self.quotaSupervisor isEnoughSpaceToUpload:[file sizeInBytes]]){

            SeafUploadFile *uploadFile  = [self createUploadFile:file into:remoteDirectory];
    
            if(FALSE == [self wasUploadedOrQueued:uploadFile]){
                //Add file to uploadQueue
                [self addToUploadQueueTask:uploadFile];                
            }
        }
        
    }
}

/**
 * Create an upload file object from a local URL and associate it with a remote directory.
 *
 * @param tree SeafSyncTree
 * @param remoteDirectory The remote directory to upload to.
 * @return An instance of SeafUploadFile.
 */
- (SeafUploadFile *)createUploadFile:(SeafSyncTree *)tree into:(SeafDir *)remoteDirectory  {
    SeafUploadFile *uploadFile = [SeafEnqueueFileFactory createFromURL:[tree getURL]];
    uploadFile.filesize = tree.sizeInBytes;
    uploadFile.udir = remoteDirectory;
    uploadFile.syncId = self.settings.identifier;
    uploadFile.syncFileId = [tree getId];
    uploadFile.onlyWifi = self.settings.uploadOnlyOverWifi;
    [uploadFile setCompletionBlock:^(SeafUploadFile *file, NSString *oid, NSError *error) {
        if(error == nil){
            [self.logService log:[[SeafSyncLogUploadFileAdapter alloc] initWith:file andOID:oid andAccount:self.connection.username]];
        }
    }];
    return uploadFile;
}

/**
 * Find a subdirectory in a directory by name.
 *
 * @param directory The parent directory to search within.
 * @param name The name of the subdirectory to find.
 * @return An instance of SeafDir representing the found subdirectory.
 */
- (SeafDir *)findSubdirectoryIn:(SeafDir *)directory withName:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafDir *subdir, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString *remoteName = [subdir.name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
        NSString *localName = [name stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
        return [remoteName isEqualToString:localName];
    }];
    NSArray *results = [[directory subDirs] filteredArrayUsingPredicate:predicate];
    return [results firstObject];
}



/**
 * Add a file to the upload queue task.
 *
 * @param fileToUpload The file to be added to the upload queue.
 */
- (void)addToUploadQueueTask:(SeafUploadFile *)fileToUpload {
    
    NSLog(@"SYNC: addToUploadQueueTask %@",fileToUpload.name);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SeafDataTaskManager.sharedObject addUploadTask:fileToUpload];
    });
}


/**
 * Check if the given SeafUploadFile was already uploaded or is in the upload queue.
 *
 * @param uploadFile The SeafUploadFile to check.
 * @return A boolean indicating whether the file was already uploaded or is in the queue.
 */
- (BOOL)wasUploadedOrQueued:(SeafUploadFile *)uploadFile {
    return
    [self fileNamed:[[uploadFile name] lastPathComponent] alreadyExistsIn: uploadFile.udir] ||
    [self fileNamed:[[uploadFile name] lastPathComponent] alreadyInUploadQueueFor:uploadFile.udir];
}



/**
 * Check if a file with the given name already exists in the target directory.
 *
 * @param fileName The name of the file to check.
 * @param targetFolder The target directory to check for the file.
 * @return A boolean indicating whether a file with the given name already exists in the target directory.
 */
- (BOOL)fileNamed:(NSString *)fileName alreadyExistsIn:(SeafDir *)targetFolder {
    return [targetFolder nameExist:fileName];
}

/**
 * Check if a file with the given name is already in the upload queue for the target directory.
 *
 * @param fileName The name of the file to check.
 * @param targetFolder The target directory to check for the file in the upload queue.
 * @return A boolean indicating whether a file with the given name is already in the upload queue for the target directory.
 */
- (BOOL)fileNamed:(NSString *)fileName alreadyInUploadQueueFor:(SeafDir *)targetFolder {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafUploadFile *uploadFile, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [uploadFile.name isEqualToString:fileName] && [uploadFile.syncId isEqualToString:self.settings.identifier];
    }];
    return [[targetFolder.uploadFiles filteredArrayUsingPredicate:predicate] count] > 0;
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
    
    NSURL *sourceFolderURL = [SeafSyncUtils urlFromBookmark:self.settings.resourceId];
    
    if(sourceFolderURL){
        
        SeafSyncTree *currentTree = [self.treeService buildFrom:sourceFolderURL  settings:self.settings];
        SeafSyncTree *treeWithChangesSinceLastSync = [self.treeService changesSinceLastSyncFor:currentTree];
        
        NSArray *treeFiles = [treeWithChangesSinceLastSync getAllChildrensOfType:TreeFile];
        
       
        [treeFiles enumerateObjectsUsingBlock:^(SeafSyncTree  *nodeOfTypeFile, NSUInteger idx, BOOL * _Nonnull stop) {
            uploadSize += [nodeOfTypeFile sizeInBytes];
        }];
    
    }
    
    return uploadSize ;
}


- (void)onEnqueueCompleted:(EnqueueCompletionBlock) handler {
    self.completionBlock = handler;
}




@end

