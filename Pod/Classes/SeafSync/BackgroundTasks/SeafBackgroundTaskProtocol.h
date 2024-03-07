/**
 *  @file SeafBackgroundTaskProtocol.h
 *  @brief Declaration of SeafBackgroundTaskProtocol.
 *
 *  Created by Javier Godoy (javigodoy@meytel.net) on 24/10/23.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BackgroundTasks/BackgroundTasks.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @brief Block type for completion handling of background tasks.
 *  @param success A boolean indicating the success of the background task.
 */
typedef void (^SeafBackgroundTaskCompleted)(BOOL success);

/**
 *  @protocol SeafBackgroundTaskProtocol
 *  @brief A protocol for defining background tasks.
 */
@protocol SeafBackgroundTaskProtocol

/**
 *  @brief Gets the background task request.
 *  @return The background task request.
 */
- (BGTaskRequest *)taskRequest API_AVAILABLE(ios(13.0));

/**
 *  @brief Gets the unique identifier for the background task.
 *  @return The unique identifier for the background task.
 */
- (NSString *)identifier;

/**
 *  @brief Runs the background task.
 *  @discussion This method is available on iOS 13.0 and later.
 */
- (void)run;

/**
 *  @brief Handles completion of the background task.
 *  @param onComplete A block to be executed upon task completion.
 */
- (void)onComplete:(SeafBackgroundTaskCompleted)onComplete;

@end

NS_ASSUME_NONNULL_END
