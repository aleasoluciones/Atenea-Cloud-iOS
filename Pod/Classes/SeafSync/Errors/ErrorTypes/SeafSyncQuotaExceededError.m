//
//  SeafSyncQuotaExceededError.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import "SeafSyncQuotaExceededError.h"
#import "SeafSyncEnums.h"

@implementation SeafSyncQuotaExceededError

- (id)init {
    return [super
            initWithDomain:@"Seafile.Sync"
            code:SeafSyncErrorQuotaExceeded
            userInfo:@{NSLocalizedDescriptionKey: [@"" stringByAppendingFormat:@"%@.%@", NSLocalizedString(@"Quota Exceeded", @"Seafile"), NSLocalizedString(@"Some of your files will not be uploaded", @"Seafile")]}];
}

@end
