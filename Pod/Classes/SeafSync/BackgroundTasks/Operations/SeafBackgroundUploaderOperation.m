/**
 * @file SeafBackgroundUploaderOperation.m
 * @brief Implementation of SeafBackgroundUploaderOperation class.
 * @author apps meytel
 * @date 8/11/23
 */

#import <Foundation/Foundation.h>
#import "SeafBackgroundUploaderOperation.h"
#import "SeafSyncronizer.h"
#import "SeafDataTaskManager.h"
#import "SeafUploadFile.h"
#import "SeafRepos.h"
#import "ExtentedString.h"
#import "Debug.h"
#import "BackgroundTasksRequestManager.h"
#import "BackgroundUploadLinkDelegate.h"
#import "SeafSyncNetworkerService.h"


@interface SeafBackgroundUploaderOperation()

@property (nonatomic, retain) dispatch_semaphore_t main_semaphore;
@property (nonatomic, retain) SeafSyncSettings *settings;
@property (nonatomic, retain) NSURLSession *session;
@property (atomic, retain) NSMutableArray *pendingCallbacks;
@property (nonatomic, retain) SeafSyncNetworkerService *networkService;

@end

@implementation SeafBackgroundUploaderOperation

#define NUMBER_OF_FILES_TO_UPLOAD 30
#define NUMBER_OF_SECONDS_TO_WAIT_BERFORE_COMPLETE 600
/**
 * Initializes an instance of SeafBackgroundUploaderOperation with the given synchronization settings and session.
 *
 * @param settings The SeafSyncSettings object representing synchronization settings.
 * @param session The NSURLSession to use for the upload.
 * @return An initialized instance of SeafBackgroundUploaderOperation.
 */
- (id)initWithSetting:(SeafSyncSettings *)settings andSession:(NSURLSession *)session {
    self = [super init];
    if (self) {
        self.settings = settings;
        self.session = session;
        self.networkService = [SeafSyncNetworkerService sharedInstanceFor:self.settings.connection];
        
    }
    return self;
}

/**
 * The main method that is called when the operation is started.
 */
- (void)main {
    if ([self isCancelled]) return;
    
    self.main_semaphore = dispatch_semaphore_create(0);
    
    __block NSArray<SeafUploadFile *> *filesToUpload = [self getFilesToUpload];
    
    // If no files to upload, exit
    if ([filesToUpload count] == 0) {
        NSLog(@"#BACKGROUND_TASKS:: SeafBackgroundUploaderOperation NO FILES TO UPLOAD for settingID %@", self.settings.identifier);
        if(self.completionBlock){
            self.completionBlock();
        }
        return;
    }

    
    filesToUpload = [filesToUpload subarrayWithRange:NSMakeRange(0, MIN(NUMBER_OF_FILES_TO_UPLOAD, filesToUpload.count))];
    
    self.pendingCallbacks = [[NSMutableArray alloc] initWithArray:filesToUpload];
    NSLog(@"#BACKGROUND_TASKS:: SeafBackgroundUploaderOperation FILES YO UPLOAD: %lu", (unsigned long)filesToUpload.count);
    
    [filesToUpload enumerateObjectsUsingBlock:^(SeafUploadFile * _Nonnull uploadFile, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSLog(@"#BACKGROUND_TASKS:: SeafBackgroundUploaderOperation UPLOADING: %@",uploadFile.name);
        
        [uploadFile run:^(id<SeafTask>  _Nonnull task, BOOL result) {
            
            // We do not check for same object´s callback.
            // We just check the number of callbacks remaining so we just remove last object from
            // pendingCallbacks array on each callback unitl the array is empty
            NSLog(@"#BACKGROUND_TASKS:: SeafBackgroundUploaderOperation CALLBACKfor NAME: %@ RECEIVED with RESULT: %d",uploadFile.name, result);
            [self.pendingCallbacks removeLastObject];
            [[self getQueueForUploadFile:(SeafUploadFile *)task] getInternalQueueTaskCompleteBlock](task, result);
            
            if(result){
                [self removeUploadFileFromManagerEnqueue:(SeafUploadFile *)task];
            }
            
            
            if(self.pendingCallbacks.count == 0){
                NSLog(@"#BACKGROUND_TASKS:: SeafBackgroundUploaderOperation ##ALL CALLBACKS RECEIVED##");
                if(self.completionBlock){
                    self.completionBlock();
                }
                return;
            }
        }];
    }];
    
    
    dispatch_semaphore_wait(self.main_semaphore, dispatch_time(DISPATCH_TIME_NOW, NUMBER_OF_SECONDS_TO_WAIT_BERFORE_COMPLETE * NSEC_PER_SEC));
    
    NSLog(@"#BACKGROUND_TASKS::self.completionBlock() TIMEOUT");
    if(self.completionBlock){
        self.completionBlock();
    }
    return;
}

/**
 * Retrieves the files to upload from UploadQueue based on synchronization settings.
 *
 * @return An array of SeafUploadFile objects to upload.
 */
- (NSArray<SeafUploadFile *> *)getFilesToUpload {
    // All files in queue for each connection
    NSMutableArray<SeafUploadFile *> *filesInQueue = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    //If conditions not passed, return empty array
    if(FALSE == [self validateConditions]){
        return [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    [[SeafSyncronizer allInstances] enumerateObjectsUsingBlock:^(SeafSyncronizer * _Nonnull syncronizer, NSUInteger idx, BOOL * _Nonnull stop) {
        [filesInQueue addObjectsFromArray:[[[SeafDataTaskManager.sharedObject accountQueueForConnection:[syncronizer getConnectionInUse]] uploadQueue] allTasks]];
    }];
    
    // Files not uploaded from my settings
    NSArray<SeafUploadFile *> *fileToReturn = [filesInQueue filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SeafUploadFile *uploadFile, NSDictionary<NSString *, id> * _Nullable bindings) {
        
        return uploadFile.isUploaded == FALSE && [uploadFile.syncId isEqualToString:self.settings.identifier] ;
    }]];
    
    //Upload small items first
    return [self sortUploadArrayBySize:fileToReturn];
}


/**
 Sorts an array of SeafUploadFile objects by file size in descending order.

 @param arrayToSort An array of SeafUploadFile objects to be sorted.
 @return An NSArray containing SeafUploadFile objects sorted by file size in descending order.
 */
- (NSArray<SeafUploadFile *> *)sortUploadArrayBySize:(NSArray<SeafUploadFile *> *)arrayToSort {
    NSSortDescriptor *sizeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"filesize" ascending:YES];
    return [arrayToSort sortedArrayUsingDescriptors:@[sizeDescriptor]];
}



-(SeafTaskQueue *) getQueueForUploadFile:(SeafUploadFile *) uploadFile{
    __block SeafTaskQueue *queue;
    [[SeafSyncronizer allInstances] enumerateObjectsUsingBlock:^(SeafSyncronizer * _Nonnull syncronizer, NSUInteger idx, BOOL * _Nonnull stop) {
        [[syncronizer settings] enumerateObjectsUsingBlock:^(SeafSyncSettings * _Nonnull setting, NSUInteger idx, BOOL * _Nonnull stop) {
            if([setting.identifier isEqualToString:uploadFile.syncId]){
                queue = [[SeafDataTaskManager.sharedObject accountQueueForConnection:[syncronizer getConnectionInUse]] uploadQueue];
                *stop = TRUE;
            }
        }];
        //If finded on below block, stop
        if(queue){
            *stop = TRUE;
        }
    }];
    return queue;
}


-(void) removeUploadFileFromManagerEnqueue:(SeafUploadFile *) uploadFile{
    [[SeafDataTaskManager.sharedObject accountQueueForConnection:self.settings.connection] removeUploadTask:uploadFile];
}

/**
 Validates the conditions for uploading.
 
 This method checks if the upload conditions are met before initiating the upload process. It considers the upload-only-over-Wi-Fi setting and the availability of a Wi-Fi connection.
 
 @return YES if the conditions are valid; otherwise, NO.
 */
- (BOOL)validateConditions {
    if (self.settings.uploadOnlyOverWifi && ![self.networkService wifiConnectionAvailable]) {
        return NO;
    }
    
    return YES;
}


@end
