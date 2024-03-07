//
//  SeafFileQueuerBackgroundTask.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 10/24/23.
//

#import "SeafFileQueuerBackgroundTask.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import "SeafSyncronizer.h"
#import "SeafBackgroundEnqueueOperation.h"




@interface SeafFileQueuerBackgroundTask ()
@property (nonatomic) SeafBackgroundTaskCompleted completionBlock;
@end

/*!
 * SeafFileQueuerBackgroundTask
 * @brief Background task for file queuing
 * @discussion This class represents a background task used for file queuing. It runs synchronization tasks for SeafSyncronizer instances.
 */
@implementation SeafFileQueuerBackgroundTask


//TASK ID
#define TASK_IDENTIFIER @"enqueuer_background_task"
#define NOT_RUN_BEFORE_NUM_MINUTES 60


- (BGTaskRequest *) taskRequest API_AVAILABLE(ios(13.0)){
    BGProcessingTaskRequest *request =  [[BGProcessingTaskRequest alloc] initWithIdentifier:[self identifier]];
    [request setRequiresExternalPower:NO];
    [request setRequiresNetworkConnectivity:YES];
    [request setEarliestBeginDate:[[NSDate date] dateByAddingTimeInterval:NOT_RUN_BEFORE_NUM_MINUTES  * 60]];
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
    
    SeafBackgroundEnqueueOperation *enqueueOperation = [[SeafBackgroundEnqueueOperation alloc] init];
    
    [enqueueOperation setCompletionBlock:^{
        if(self.completionBlock){
            self.completionBlock(TRUE);
        }
    }];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperation:enqueueOperation];
    [operationQueue setSuspended:NO];

}

- (void) onComplete:(SeafBackgroundTaskCompleted) onComplete{
    self.completionBlock  = onComplete;
}

@end
