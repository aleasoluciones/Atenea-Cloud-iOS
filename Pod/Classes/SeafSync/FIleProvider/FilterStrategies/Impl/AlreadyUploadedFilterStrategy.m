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
#import "SeafStorage.h"

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
 * @brief Check if this file is in the queue
 *
 * @return return true is file is already in the queue
 */
-(BOOL) fileInUploadQueue:(id<SeafSyncItemProtocol>) syncItem{
    
    //Instead of read from self.taskQueue.uploadQueue, we read from the storage source because often the uploadQueue is still not loaded and sometime the filter says this file is not in queue, but is already in queue.
    
    NSString *uploadKey = [self.taskManager uploadStorageKey:self.settings.connection.accountIdentifier];
    NSMutableDictionary *uploadTasks = [NSMutableDictionary dictionaryWithDictionary: [SeafStorage.sharedObject objectForKey:uploadKey]];
    
    BOOL existsInQueue = FALSE;
    
    for (NSString *key in uploadTasks) {
        NSDictionary *dict = [uploadTasks objectForKey:key];
        NSString *syncId = [[dict objectForKey:@"syncId"] stringValue];
        NSString *syncFileId = [[dict objectForKey:@"syncFileId"] stringValue];
        
        if([syncId isEqualToString: self.settings.identifier] && [syncFileId  isEqualToString:syncItem.identifier]){
            existsInQueue = TRUE;
            break;
        }
        
    }
    
    return existsInQueue;

}

/**
 *
 * This function is no longer in use: Last time used 08/04/2024.
 *
 *
 * @brief Check if this file is in the queue
 *
 * @return return true is file is already in the queue
 */
-(BOOL) fileInUploadQueue_V1:(id<SeafSyncItemProtocol>) syncItem{
    
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
