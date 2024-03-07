//
//  SeafSyncTargetNotFoundError.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import "SeafSyncTargetNotFoundError.h"
#import "SeafSyncEnums.h"

@implementation SeafSyncTargetNotFoundError

- (id)init {
    return [super
            initWithDomain:@"Seafile.Sync"
            code:SeafSyncErrorTargetNotFound
            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Target folder not found", @"Seafile")}];
}

@end
