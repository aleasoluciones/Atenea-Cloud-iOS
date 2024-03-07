//
//  SeafQuotaSupervisor.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net)on 10/10/23.
//

#import "SeafQuotaSupervisor.h"
#import "SeafDataTaskManager.h"


/**
 * @brief Private interface for SeafQuotaSupervisor.
 */
@interface SeafQuotaSupervisor()
@property SeafConnection *connection; /**< The SeafConnection associated with the quota supervisor. */
@property SeafDataTaskManager *taskManager; /**< The task manager for managing data tasks. */
@property SeafAccountTaskQueue *taskQueue; /**< The task queue associated with the SeafConnection. */

 ///< List of shared SeafSyncronizer instances.
///<
@end

/**
 * @brief Implementation of SeafQuotaSupervisor.
 */
@implementation SeafQuotaSupervisor

static NSMutableArray<SeafQuotaSupervisor *> *sharedInstances = nil;


/**
 * Gets SeafQuotaSupervisor instance for connection.
 *
 * @param connection The SeafConnection instance.
 * @return A shared instance of SeafSyncronizer.
 */
+ (instancetype)sharedInstanceFor:(SeafConnection *) connection; {
    
    if(sharedInstances == nil){
        sharedInstances = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    SeafQuotaSupervisor *supervisor = [SeafQuotaSupervisor getInstaceFor:connection];
    if(supervisor != nil){
        return supervisor;
    }

    // Create for this connection
    supervisor = [[SeafQuotaSupervisor alloc] initWithConnection:connection];
    [sharedInstances addObject:supervisor];
    return supervisor;
}

/**
 * Gets the unique instance for a connection.
 *
 * @param connection The SeafConnection instance.
 * @return The unique instance of SeafSyncronizer for the specified connection.
 */
+ (instancetype)getInstaceFor:(SeafConnection *)connection {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafQuotaSupervisor  *supervisor, NSDictionary<NSString *,id> * _Nullable bindings) {
        return supervisor.connection == connection;
    }];
    return [[sharedInstances filteredArrayUsingPredicate:predicate] firstObject];
}




/**
 * @brief Initializes a new instance of SeafQuotaSupervisor with a specified SeafConnection.
 *
 * @param connection The SeafConnection associated with the quota supervisor.
 * @return An initialized instance of SeafQuotaSupervisor.
 */
-(id) initWithConnection:(SeafConnection *) connection{
    self = [super init];
    if(self){
        self.connection = connection;
        [self refreshAvailableSpaceFromSource];
        self.taskManager = [SeafDataTaskManager sharedObject];
        self.taskQueue = [self.taskManager accountQueueForConnection:self.connection];
    }
    return self;
}

/**
 * @brief Checks if there is enough space to upload the specified number of bytes.
 *
 * @param sizeInBytes The number of bytes to check for available space.
 * @return A boolean indicating whether there is enough space.
 */
-(BOOL) isEnoughSpaceToUpload:(long long) sizeInBytes{
    return  [self getAvailableSpace] >= sizeInBytes;
}

/**
 * @brief Gets the available space for the associated SeafConnection.
 *
 * @return The available space.
 */
-(long long) getAvailableSpace{
   return MAX([self getTotalSpace] - ([self getUsedSpace] + [self getUploadQueueSize]),0);
}

/**
 * @brief Gets the used space for the associated SeafConnection.
 *
 * @return The used space.
 */
-(long long) getUsedSpace{
   return self.connection.usage;
}

/**
 * @brief Gets the total space for the associated SeafConnection.
 *
 * @return The total space.
 */
-(long long) getTotalSpace{
   return self.connection.quota;
}

/**
 * @brief Gets the total size of files in the upload queue.
 *
 * @return The total size of files in the upload queue.
 */
-(long long) getUploadQueueSize{
    __block long long queueSize = 0;
    [[self.taskQueue.uploadQueue allTasks] enumerateObjectsUsingBlock:^(SeafUploadFile *uploadFile, NSUInteger idx, BOOL * _Nonnull stop) {
        queueSize += uploadFile.filesize;
    }];
    return queueSize;
}

/**
 * @brief Refreshes the available space by querying the account information from the source.
 */
-(void) refreshAvailableSpaceFromSource{
    [self.connection getAccountInfo:nil];
}



-(void) getFreshAvailableSpace:(void (^ _Nullable)(long long size))callback{
    [self.connection getAccountInfo:^(bool result) {
        callback([self getAvailableSpace]);
    }];
}

@end

