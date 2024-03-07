/**
 *  @file SeafBackgroundTasksManager.h
 *  @brief Declaration of SeafBackgroundTasksManager class.
 *
 *  Created by Javier Godoy (javigodoy@meytel.net) on 24/10/23.
 */

#import <Foundation/Foundation.h>
#import "SeafBackgroundTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @brief SeafBackgroundTasksManager class responsible for managing background tasks.
 */
@interface SeafBackgroundTasksManager : NSObject

/**
 *  @brief Singleton instance of SeafBackgroundTasksManager.
 *  @return An instance of SeafBackgroundTasksManager.
 */
+ (instancetype)sharedInstance;

/**
 *  @brief Gets the array of background tasks.
 *  @return An array of background tasks.
 */
- (NSArray<id<SeafBackgroundTaskProtocol>> *)getTasks;

/**
 *  @brief Submits all background tasks to the background task scheduler.
 */
- (void)submitBackgroundAllTasks;

/**
 *  @brief Submits a specific background task to the background task scheduler.
 *  @param task The background task to be submitted.
 */
- (void)submitBackgroundTask:(id<SeafBackgroundTaskProtocol>)task;

@end

NS_ASSUME_NONNULL_END
