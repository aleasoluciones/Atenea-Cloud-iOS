/**
 *  @file SeafRecoveryItem.h
 *  @brief Header file for SeafDeletedFileFolderItem class.
 *
 *  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
 */

#import <Foundation/Foundation.h>
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum SeafRecoveryItemType
 *  Represents the type of a recovery item.
 */
typedef NS_ENUM(NSInteger, SeafRecoveryItemType) {
    SeafRecoveryItemTypeRepository, ///< Represents a repository.
    SeafRecoveryItemTypeFolder, ///< Represents a folder within a repository.
    SeafRecoveryItemTypeFile, ///< Represents a file within a repository.
    SeafRecoveryItemTypeDirent ///< Represents a file within a repository.
};

/**
 *  @protocol SeafRecoveryItem
 *  Defines a protocol for recovery items.
 */
@protocol SeafRecoveryItem


-(NSString *)name;

-(NSInteger) sizeInBytes;

-(NSString *) path;

-(NSString *) fullPath;

-(NSString *) commitId;

-(NSString *) repositoryId;

-(BOOL) isDir;

-(SeafRecoveryItemType) recoveryItemType;

/**
 Recovers items using the specified Seafile connection.

 This method initiates the recovery process using the provided Seafile connection. Upon completion, the success status is communicated through the provided callback block.

 @param connection The Seafile connection to be used for recovery.
 @param callback A block to be executed upon the completion of the recovery operation. The block takes a single parameter, `success`, indicating whether the recovery was successful or not.

 */
- (void)recoverUsing:(SeafConnection *)connection callback:(void (^ _Nullable)(BOOL success))callback;


/**
 Reverts the recovery operation using the specified Seafile connection.

 This method sends a DELETE request to revert the recovery operation for the associated repository using the provided Seafile connection.

 @param connection The Seafile connection to be used for reverting the recovery operation.

 */
-(void) revertRecoveryUsing:(SeafConnection *) connection;

@end

NS_ASSUME_NONNULL_END
