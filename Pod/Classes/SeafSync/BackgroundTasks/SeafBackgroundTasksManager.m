/**
 *  @file SeafBackgroundTasksManager.m
 *  @brief Implementation of SeafBackgroundTasksManager class.
 *
 *  Created by Javier Godoy (javigodoy@meytel.net) on 24/10/23.
 */

#import "SeafBackgroundTasksManager.h"
#import "SeafBackgroundTaskProtocol.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import "SeafFileQueuerBackgroundTask.h"
#import "SeafDataTaskManager.h"
#import "SeafSyncronizer.h"
#import "SeafBackupExpiratorBackgroundTask.h"
#import "SeafUploadQueueBackgroundTask.h"

/**
 *  @brief Private interface for SeafBackgroundTasksManager.
 */
@interface SeafBackgroundTasksManager ()

@property NSMutableArray<id<SeafBackgroundTaskProtocol>> *tasks; ///< Array to store background tasks.

@end

/**
 *  @brief Implementation of SeafBackgroundTasksManager class.
 */
@implementation SeafBackgroundTasksManager

/**
 *  @brief Singleton instance of SeafBackgroundTasksManager.
 *  @return An instance of SeafBackgroundTasksManager.
 */
+ (instancetype)sharedInstance {
    static SeafBackgroundTasksManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[SeafBackgroundTasksManager alloc] init];
        [sharedInstance initialize];
    });

    return sharedInstance;
}

/**
 *  @brief Initializes the SeafBackgroundTasksManager.
 */
- (void)initialize {
    self.tasks = [[NSMutableArray alloc] initWithCapacity:0];
    [self.tasks addObject:[[SeafUploadQueueBackgroundTask alloc] init]];
    [self.tasks addObject:[[SeafFileQueuerBackgroundTask alloc] init]];
    [self.tasks addObject:[[SeafBackupExpiratorBackgroundTask alloc] init]];
}

/**
 *  @brief Gets the array of background tasks.
 *  @return An array of background tasks.
 */
- (NSArray<id<SeafBackgroundTaskProtocol>> *)getTasks {
    return self.tasks;
}

/**
 *  @brief Finds a background task by identifier.
 *  @param identifier The identifier of the task to find.
 *  @return The background task with the specified identifier.
 */
- (id<SeafBackgroundTaskProtocol>)findTaskByIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id<SeafBackgroundTaskProtocol> _Nullable seafTask, NSDictionary<NSString *, id> * _Nullable bindings) {
        return [[seafTask identifier] isEqualToString:identifier];
    }];

    return [[self.tasks filteredArrayUsingPredicate:predicate] firstObject];
}

/**
 *  @brief Submits all background tasks to the background task scheduler.
 */
- (void)submitBackgroundAllTasks {
    [[self getTasks] enumerateObjectsUsingBlock:^(id<SeafBackgroundTaskProtocol> task, NSUInteger idx, BOOL * _Nonnull stop) {
        [self submitBackgroundTask:task];
    }];
}

/**
 *  @brief Submits a specific background task to the background task scheduler.
 *  @param task The background task to be submitted.
 */
/*
- (void)submitBackgroundTask:(id<SeafBackgroundTaskProtocol>)task {
    NSError *error = nil;
    if (@available(iOS 13.0, *)) {
        [BGTaskScheduler.sharedScheduler submitTaskRequest:[task taskRequest] error:&error];

        if (error) {
            NSLog(@"SYNC: Error scheduling background task: %@", error);
            return;
        }

        NSLog(@"SYNC: Scheduling background task OK: %@", task.identifier);
    }
}
*/

- (void)submitBackgroundTask:(id<SeafBackgroundTaskProtocol>)task {
    NSError *error = nil;
    if (@available(iOS 13.0, *)) {
        BGTaskRequest *taskRequest = [task taskRequest];
        [BGTaskScheduler.sharedScheduler submitTaskRequest:taskRequest error:&error];
        
        if (error) {
            NSLog(@"SYNC: Error scheduling background task: %@ (Code: %ld)",
                  error.localizedDescription, (long)error.code);
            
            // Códigos de error comunes:
            // BGTaskSchedulerErrorCodeUnavailable = 1
            // BGTaskSchedulerErrorCodeTooManyPendingTaskRequests = 2
            // BGTaskSchedulerErrorCodeNotPermitted = 3
            
            switch (error.code) {
                case 1: // BGTaskSchedulerErrorCodeUnavailable
                    NSLog(@"SYNC: Background tasks unavailable");
                    break;
                case 2: // BGTaskSchedulerErrorCodeTooManyPendingTaskRequests
                    NSLog(@"SYNC: Too many pending tasks");
                    break;
                case 3: // BGTaskSchedulerErrorCodeNotPermitted
                    NSLog(@"SYNC: Task not permitted - check Info.plist");
                    break;
                default:
                    NSLog(@"SYNC: Unknown error code: %ld", (long)error.code);
                    break;
            }
            return;
        }
        NSLog(@"SYNC: Background task scheduled successfully: %@", task.identifier);
    }
}



@end
