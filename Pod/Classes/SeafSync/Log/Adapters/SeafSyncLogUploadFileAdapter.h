//
//  SeafSyncLogUploadFileAdapter.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 10/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafUploadFile.h"
#import "SeafSyncLog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncLogUploadFileAdapter
 * @brief Adapter class for adapting SeafUploadFile to SeafSyncLog.
 */
@interface SeafSyncLogUploadFileAdapter : SeafSyncLog

/**
 * Initializes a new instance of SeafSyncLogUploadFileAdapter with the provided SeafUploadFile and account name.
 * @param uploadFile The SeafUploadFile to be adapted.
 * @param accountName The account name associated with the upload file.
 * @return An initialized SeafSyncLogUploadFileAdapter object.
 */
- (id)initWith:(SeafUploadFile *)uploadFile andAccount:(NSString *)accountName;

/**
 * Initializes a new instance of SeafSyncLogUploadFileAdapter with the provided SeafUploadFile, object ID, and account name.
 * @param uploadFile The SeafUploadFile to be adapted.
 * @param oid The object ID associated with the upload file.
 * @param accountName The account name associated with the upload file.
 * @return An initialized SeafSyncLogUploadFileAdapter object.
 */
- (id)initWith:(SeafUploadFile *)uploadFile andOID:(NSString *)oid andAccount:(NSString *)accountName;

@end

NS_ASSUME_NONNULL_END
