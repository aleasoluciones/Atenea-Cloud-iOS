/**
 *  @file SeafTrashRecoverer.h
 *  @brief Header file for SeafTrashRecoverer class.
 *
 *  Created by Javier Godoy (javigodoy@meytel.net) on 31/10/23.
 */

#import <Foundation/Foundation.h>
#import "SeafConnection.h"
#import "SeafRecoveryItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum SeafRecoveryResult
 *  Represents the result of a recovery operation.
 */
typedef NS_ENUM(NSInteger, SeafRecoveryResult) {
    SeafRecoveryResultSuccess, ///< The recovery operation was successful.
    SeafRecoveryResultError, ///< An error occurred during the recovery operation.
    SeafRecoveryResultErrorQuota ///< The recovery operation failed due to quota limitations.
};

/**
 *  @class SeafTrashRecoverer
 *  Handles the recovery of deleted items from Seafile repositories.
 */
@interface SeafTrashRecoverer : NSObject

/**
 *  Initializes a SeafTrashRecoverer object with a connection.
 *
 *  @param connection The SeafConnection object associated with the recoverer.
 *
 *  @return A SeafTrashRecoverer object.
 */
- (id) initWitConnection:(SeafConnection *) connection;

/**
 *  Checks if there is enough quota space available for a recovery item.
 *
 *  @param recoveryItems The recovery items array to check.
 *
 *  @return YES if there is enough space, NO otherwise.
 */
-(BOOL) quotaAvailableSpaceForItems:(NSArray<id<SeafRecoveryItem>> *) recoveryItems;

/**
 *  Recovers a recovery item.
 *
 *  @param recoveryItem The recovery item to recover.
 *  @param callback A callback block to handle the recovery result.
 */
- (void)recover:(id<SeafRecoveryItem>)recoveryItem callback:(void (^ _Nullable)(SeafRecoveryResult result))callback;



/**
 Refreshes the user's quota by fetching fresh available space from the quota supervisor.

 @param callback A block to be executed after the quota is refreshed.
 */
-(void) refreshQuota:(void (^ _Nullable)(void))callback;


/**
 * @brief Clears the trash for a specific repository.
 *
 * This method removes the trashed items associated with the specified repository.
 *
 * @param repositoryId The unique identifier of the repository.
 * @param success A block that will be called upon successful completion of the operation.
 *                The block takes a single parameter, a BOOL value indicating the success of the operation.
 *                If the operation is successful, the BOOL parameter will be set to YES; otherwise, it will be set to NO.
 */
-(void) clearTrash:(NSString *) repositoryId callback:(void (^)(BOOL success))success;


@end

NS_ASSUME_NONNULL_END
