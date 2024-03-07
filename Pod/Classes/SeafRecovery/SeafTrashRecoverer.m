/**
 *  @file SeafTrashRecoverer.m
 *  @brief Implementation of SeafTrashRecoverer class.
 *
 *  Created by Javier Godoy (javigodoy@meytel.net) on 31/10/23.
 */

#import "SeafTrashRecoverer.h"
#import "SeafRecoveryItem.h"
#import "Debug.h"
#import "ExtentedString.h"
#import "SeafQuotaSupervisor.h"
#import "SeafDeletedFileFolderItem.h"
#import "SeafDeletedRepoItem.h"

/**
 *  @private
 *  Private interface for SeafTrashRecoverer.
 */
@interface SeafTrashRecoverer ()

@property SeafConnection *connection;
@property SeafQuotaSupervisor *quotaSupervisor;

@end

@implementation SeafTrashRecoverer

/**
 *  Initializes a SeafTrashRecoverer object with a connection.
 *
 *  @param connection The SeafConnection object associated with the recoverer.
 *
 *  @return A SeafTrashRecoverer object.
 */
-(id) initWitConnection:(SeafConnection *) connection {
    self = [super init];
    if(self) {
        self.connection = connection;
        self.quotaSupervisor = [SeafQuotaSupervisor sharedInstanceFor:self.connection];
    }
    return self;
}

/**
 *  Checks if there is enough quota space available for a recovery item.
 *
 *  @param recoveryItem The recovery item to check.
 *
 *  @return YES if there is enough space, NO otherwise.
 */
-(BOOL) quotaAvailableSpaceFor:(id<SeafRecoveryItem>)recoveryItem {
    return [self.quotaSupervisor isEnoughSpaceToUpload:recoveryItem.sizeInBytes];
}

/**
 *  Checks if there is enough quota space available for a recovery item.
 *
 *  @param recoveryItems The recovery items array to check.
 *
 *  @return YES if there is enough space, NO otherwise.
 */
-(BOOL) quotaAvailableSpaceForItems:(NSArray<id<SeafRecoveryItem>> *) recoveryItems {
    
    __block long requiredSpace = 0;
    [recoveryItems enumerateObjectsUsingBlock:^(id<SeafRecoveryItem>  _Nonnull itemToRecover, NSUInteger idx, BOOL * _Nonnull stop) {
        requiredSpace += itemToRecover.sizeInBytes;
    }];
    
    return [self.quotaSupervisor isEnoughSpaceToUpload:requiredSpace];
}

/**
 *  Recovers a recovery item from a repository.
 *
 *  @param recoveryItem The recovery item to recover.
 *  @param callback A callback block to handle the recovery result.
 */
- (void)recover:(id<SeafRecoveryItem>)recoveryItem callback:(void (^ _Nullable)(SeafRecoveryResult result))callback {
    
    //Refresh quota
    [self.quotaSupervisor getFreshAvailableSpace:^(long long size) {
        
        // If item size exceeds the available space, just return
        if (![self quotaAvailableSpaceFor:recoveryItem]) {
            callback(SeafRecoveryResultErrorQuota);
            return;
        }
        
        //Call to recover
        [recoveryItem recoverUsing:self.connection callback:^(BOOL success) {
            
            if (!success) {
                callback(SeafRecoveryResultError);
                return;
            }
            
            [self quotaExceededAfterRecovery:^(BOOL quotaExceeded) {
                // No quota exceeded, return Success
                if(!quotaExceeded){
                    callback(SeafRecoveryResultSuccess);
                    return;
                }
                
                // Quota exceeded. Revert recovery
                [recoveryItem revertRecoveryUsing:self.connection];
                callback(SeafRecoveryResultErrorQuota);
            }];
        }];
    }];
    


}

/**
 Refreshes the user's quota by fetching fresh available space from the quota supervisor.

 @param callback A block to be executed after the quota is refreshed.
 */
-(void) refreshQuota:(void (^ _Nullable)(void))callback{
    [self.quotaSupervisor getFreshAvailableSpace:^(long long size) {
        callback();
    }];
}

/**
 *  Checks if the quota is exceeded after recovery.
 *
 *  @param callback A callback block to handle the result.
 */
-(void) quotaExceededAfterRecovery:(void (^ _Nullable)(BOOL quotaExceeded))callback{
    [self.quotaSupervisor getFreshAvailableSpace:^(long long size) {
        callback(size <= 0);
    }];
}


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
-(void) clearTrash:(NSString *) repositoryId callback:(void (^)(BOOL success))success{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/repos/%@/trash/", API_URL_V21, repositoryId ];
    
    [self.connection sendDelete:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        success(TRUE);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        success(FALSE);
    }];
}




@end

