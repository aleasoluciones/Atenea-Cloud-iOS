//
//  AlreadyUploadedFilterStrategy.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 13/10/23.
//

#import "AlreadyUploadedFilterStrategy.h"
#import "SeafSyncLogsService.h"
#import "SeafSyncUtils.h"
#import "SeafDataTaskManager.h"
#import "SeafUploadFile.h"

@interface AlreadyUploadedFilterStrategy()

@property SeafSyncLogsService *logService;
@property SeafSyncSettings *settings;
@property SeafDataTaskManager *taskManager; /**< The task manager for managing data tasks. */
@property SeafAccountTaskQueue *taskQueue; /**< The task queue associated with the SeafConnection. */

@end

@implementation AlreadyUploadedFilterStrategy

/**
 * @brief Initializes a new instance of the filter strategy with the specified synchronization settings.
 *
 * @param settings The synchronization settings to be used by the filter strategy.
 * @return An initialized instance of the filter strategy.
 */
-(id)initWithSettings:(SeafSyncSettings *)settings{
    self = [super init];
    if(self){
        self.settings = settings;
        self.logService = [[SeafSyncLogsService alloc] initWithConnection:self.settings.connection];
        self.taskManager = [SeafDataTaskManager sharedObject];
        self.taskQueue = [self.taskManager accountQueueForConnection:self.settings.connection];
    }
    
    return self;
}


/**
 * @brief Determines whether the provided item meets the specified conditions based on synchronization settings.
 *
 * @param itemToEvaluate The item to evaluate against the conditions.
 * @return YES if the item meets the conditions, NO otherwise.
 */
-(BOOL) meetsCondition:(id<SeafSyncItemProtocol>) itemToEvaluate{
    
    return FALSE == [self fileInUploadQueue:itemToEvaluate] &&  FALSE == [self.logService isAlreadyLogged:[self createLogToFind:itemToEvaluate]];
    
}

/**
 * @brief Gets the total size of files in the upload queue.
 *
 * @return The total size of files in the upload queue.
 */
-(BOOL) fileInUploadQueue:(id<SeafSyncItemProtocol>) syncItem{
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafUploadFile *uploadFile, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [uploadFile.syncId isEqualToString: self.settings.identifier] && [uploadFile.syncFileId isEqualToString:syncItem.identifier];
    }];
    
    NSArray *result = [[self.taskQueue.uploadQueue allTasks] filteredArrayUsingPredicate:predicate];
    return [result count] > 0 ;
}




-(SeafSyncLog *) createLogToFind:(id<SeafSyncItemProtocol>) syncItem{
    SeafSyncLog *log = [[SeafSyncLog alloc] init];
    log.resourceId = syncItem.identifier;
    log.syncSettingId = self.settings.identifier;
    return log;
}
@end
