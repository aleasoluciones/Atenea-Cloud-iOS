//
//  SeafSyncErrorFactory.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import "SeafSyncErrorFactory.h"

#import "SeafSyncTargetNotFoundError.h"
#import "SeafSyncQuotaExceededError.h"
#import "SeafSyncSourceNotFoundError.h"

@implementation SeafSyncErrorFactory

/**
 * Creates an NSError instance based on the specified SeafSyncError code.
 *
 * @param errorCode The SeafSyncError code to create an error for.
 * @return An NSError instance representing the specified error code.
 */
+ (NSError *)createFrom:(SeafSyncError)errorCode {
    switch (errorCode) {
        case SeafSyncErrorTargetNotFound:
            return [[SeafSyncTargetNotFoundError alloc] init];
            break;

        case SeafSyncErrorFolderNotFound:
            return [[SeafSyncTargetNotFoundError alloc] init];
            break;

        case SeafSyncErrorQuotaExceeded:
            return [[SeafSyncQuotaExceededError alloc] init];
            break;

        default:
            return nil;
            break;
    }
}

@end
