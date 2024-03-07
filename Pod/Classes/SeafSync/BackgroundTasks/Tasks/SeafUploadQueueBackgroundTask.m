/**
 * @file SeafUploadQueueBackgroundTask.m
 * @brief Implementation of SeafUploadQueueBackgroundTask class.
 * @author apps meytel
 * @date 24/10/23
 */

#import "SeafUploadQueueBackgroundTask.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import "SeafDataTaskManager.h"
#import "SeafSyncronizer.h"
#import "SeafBackgroundUploaderOperation.h"
#import "BackgroundTasksRequestManager.h"
#import "SeafSyncSettings.h"

@interface SeafUploadQueueBackgroundTask ()

/**
 * @brief The completion block to be executed when the background task completes.
 * @see SeafBackgroundTaskCompleted
 */
@property (nonatomic) SeafBackgroundTaskCompleted completionBlock;

/**
 * @brief The background NSURLSession used for uploading.
 */
@property (nonatomic, retain) NSURLSession *backgroundSession;

@end

@implementation SeafUploadQueueBackgroundTask

//TASK ID
#define TASK_IDENTIFIER @"uploader_background_task"
#define NOT_RUN_BEFORE_NUM_MINUTES 10

/**
 * @brief Initializes an instance of SeafUploadQueueBackgroundTask.
 * @return An initialized instance of SeafUploadQueueBackgroundTask.
 */
- (id)init {
    self = [super init];
    if (self) {
        [self configureSession];
    }
    return self;
}

/**
 * @brief Configures the background NSURLSession for uploading.
 */
- (void)configureSession {
    NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.seafile.backgroundSession.uploader"];
    backgroundConfig.allowsCellularAccess = TRUE;
    backgroundConfig.networkServiceType = NSURLNetworkServiceTypeBackground;
    backgroundConfig.waitsForConnectivity = TRUE;
    backgroundConfig.discretionary = TRUE;
    backgroundConfig.sessionSendsLaunchEvents = TRUE;
    backgroundConfig.shouldUseExtendedBackgroundIdleMode = TRUE;

    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:[BackgroundTasksRequestManager sharedInstance] delegateQueue:nil];
}

/**
 * @brief Creates a background task request.
 * @return A BGTaskRequest object representing the task request.
 * @availability iOS 13.0 and later
 */
- (BGTaskRequest *)taskRequest API_AVAILABLE(ios(13.0)) {
    BGProcessingTaskRequest *request = [[BGProcessingTaskRequest alloc] initWithIdentifier:[self identifier]];
    [request setRequiresExternalPower:NO];
    [request setRequiresNetworkConnectivity:YES];
    [request setEarliestBeginDate:[[NSDate date] dateByAddingTimeInterval:NOT_RUN_BEFORE_NUM_MINUTES * 60]];
    return request;
}

/**
 * @brief Returns the task identifier.
 * @return A unique task identifier.
 */
- (NSString *)identifier {
    return [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingFormat:@".%@", TASK_IDENTIFIER];
}

/**
 * @brief Runs the background task.
 * @availability iOS 13.0 and later
 */
- (void)run{
    // If Queue is empty, exit
    if (![self existsPendingFilesInQueue]) {
        NSLog(@"#BACKGROUND_TASKS::  UPLOAD:: NO FILES TO UPLOAD");
        if(self.completionBlock){
            self.completionBlock(TRUE);
        }
        return;
    }
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setSuspended:YES];

    // Add operations to queue
    [[self loadSettings] enumerateObjectsUsingBlock:^(SeafSyncSettings *settings, NSUInteger idx, BOOL * _Nonnull stop) {
        SeafBackgroundUploaderOperation *uploadOperation = [[SeafBackgroundUploaderOperation alloc] initWithSetting:settings andSession:self.backgroundSession];
        [uploadOperation setCompletionBlock:^{
            if (operationQueue.operationCount == 0) {
                NSLog(@"#BACKGROUND_TASKS:: UPLOAD:: ALL CALLBACKS RECEIVED");
                if(self.completionBlock){
                    self.completionBlock(TRUE);
                }
            }
        }];
        [operationQueue addOperation:uploadOperation];
    }];

    // Run operations
    [operationQueue setSuspended:NO];
}

/**
 * @brief Checks if there are pending files in the upload queue.
 * @return `YES` if there are pending files, `NO` otherwise.
 */
- (BOOL)existsPendingFilesInQueue {
    __block BOOL pendingFiles = FALSE;

    [[SeafSyncronizer allInstances] enumerateObjectsUsingBlock:^(SeafSyncronizer * _Nonnull syncronizer, NSUInteger idx, BOOL * _Nonnull stop) {
        pendingFiles = [[[[SeafDataTaskManager.sharedObject accountQueueForConnection:[syncronizer getConnectionInUse]] uploadQueue] allTasks] count] > 0;
        if (pendingFiles) {
            *stop = TRUE;
        }
    }];

    return pendingFiles;
}

/**
 * @brief Loads synchronization settings from all SeafSyncronizer instances.
 * @return An array of SeafSyncSettings objects.
 */
- (NSMutableArray<SeafSyncSettings *> *)loadSettings {
    NSMutableArray<SeafSyncSettings *> *allSettings = [[NSMutableArray alloc] initWithCapacity:0];
    [[SeafSyncronizer allInstances] enumerateObjectsUsingBlock:^(SeafSyncronizer * _Nonnull syncronizer, NSUInteger idx, BOOL * _Nonnull stop) {
        [allSettings addObjectsFromArray:syncronizer.settings];
    }];
    return allSettings;
}

/**
 * @brief Sets the completion block to be executed when the background task completes.
 * @param onComplete The completion block.
 */
- (void)onComplete:(SeafBackgroundTaskCompleted)onComplete {
    self.completionBlock = onComplete;
}

@end

