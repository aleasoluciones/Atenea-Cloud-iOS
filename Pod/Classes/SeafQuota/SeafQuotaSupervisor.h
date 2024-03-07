//
//  SeafQuotaSupervisor.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net)on 10/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafConnection.h"
#import "SeafUploadFile.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief SeafQuotaSupervisor class to manage quota and space-related operations.
 */
@interface SeafQuotaSupervisor : NSObject


+ (instancetype)sharedInstanceFor:(SeafConnection *) connection;


/**
 * @brief Checks if there is enough space to upload the specified number of bytes.
 *
 * @param sizeInBytes The number of bytes to check for available space.
 * @return A boolean indicating whether there is enough space.
 */
-(BOOL) isEnoughSpaceToUpload:(long long) sizeInBytes;

/**
 * @brief Gets the available space for the associated SeafConnection.
 *
 * @return The available space.
 */
-(long long) getAvailableSpace;


/**
 * @brief Gets the available space for the associated SeafConnectio calling directly to API.

 */
-(void) getFreshAvailableSpace:(void (^ _Nullable)(long long size))callback;

/**
 * @brief Gets the total size of files in the upload queue.
 *
 * @return The total size of files in the upload queue.
 */
-(long long) getUploadQueueSize;

@end

NS_ASSUME_NONNULL_END
