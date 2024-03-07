//
//  SeafBackupExpiratorBackgroundTask.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 13/11/23.
//

#import "SeafBackupExpiratorBackgroundTask.h"
#import "SeafSyncronizer.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import "SeafSyncronizer.h"
#import "SeafBackgroundEnqueueOperation.h"
#import "SeafBackgroundExpireOperation.h"



@interface SeafBackupExpiratorBackgroundTask ()
@property (nonatomic) SeafBackgroundTaskCompleted completionBlock;
@end

/*!
 * SeafBackupExpiratorBackgroundTask
 * @brief Background task for file queuing
 * @discussion This class represents a background task used for file queuing. It runs synchronization tasks for SeafSyncronizer instances.
 */
@implementation SeafBackupExpiratorBackgroundTask


//TASK ID
#define TASK_IDENTIFIER @"expirator_background_task"
#define NOT_RUN_BEFORE_NUM_MINUTES 720


- (BGTaskRequest *) taskRequest API_AVAILABLE(ios(13.0)){
    BGProcessingTaskRequest *request =  [[BGProcessingTaskRequest alloc] initWithIdentifier:[self identifier]];
    [request setRequiresExternalPower:NO];
    [request setRequiresNetworkConnectivity:YES];
    [request setEarliestBeginDate:[[NSDate date] dateByAddingTimeInterval:NOT_RUN_BEFORE_NUM_MINUTES * 60]];
    
    return request;
}


/*!
 * @brief Returns the task identifier
 * @return A unique task identifier.
 */
- (NSString *)identifier {
    return [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingFormat:@".%@", TASK_IDENTIFIER];
}

/*!
 * @brief Runs the background task
 * @availability iOS 13.0 and later
 */
- (void)run {
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    
    SeafBackgroundExpireOperation *expirationOperation = [[SeafBackgroundExpireOperation alloc] init];
    [expirationOperation setCompletionBlock:^{
        if(self.completionBlock){
            self.completionBlock(TRUE);
        }
    }];
    [operationQueue addOperation:expirationOperation];
    [operationQueue setSuspended:NO];
    
}


- (void) onComplete:(SeafBackgroundTaskCompleted) onComplete{
    self.completionBlock  = onComplete;
}

@end
