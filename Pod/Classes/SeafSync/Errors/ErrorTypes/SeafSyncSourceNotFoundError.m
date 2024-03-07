//
//  SeafSyncSourceNotFoundError.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import "SeafSyncSourceNotFoundError.h"
#import "SeafSyncEnums.h"

@implementation SeafSyncSourceNotFoundError

- (id)init {
    return [super
            initWithDomain:@"Seafile.Sync"
            code:SeafSyncErrorFolderNotFound
            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Source folder not found", @"Seafile")}];
}

@end
