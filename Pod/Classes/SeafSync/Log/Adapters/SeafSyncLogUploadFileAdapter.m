//
//  SeafSyncLogUploadFileAdapter.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 10/11/23.
//

#import "SeafSyncLogUploadFileAdapter.h"
#import "SeafSyncUtils.h"
#import "SeafRepos.h"

@interface SeafSyncLogUploadFileAdapter ()

@property SeafUploadFile *uploadFile;
@property NSString *oid;
@property NSString *accountName;
@end


@implementation SeafSyncLogUploadFileAdapter

-(id) initWith:(SeafUploadFile *) uploadFile andAccount:(NSString *) accountName{
    self = [super init];
    if(self){
        self.uploadFile = uploadFile;
        self.accountName = accountName;
    }
    return self;
}


-(id) initWith:(SeafUploadFile *) uploadFile andOID:(NSString *) oid andAccount:(NSString *) accountName{
    self = [self initWith:uploadFile andAccount:accountName];
    if(self){
        self.oid = oid;
    }
    
    return self;
}

/**
 * @brief The identifier (e.g., folder Id or album Id) from where files must be loaded.
 */
-(id) accountId{
    return self.accountName;
}

/**
 * @brief The date of creation of this sync log.
 */
-(NSDate *) uploadedDate{
    return [NSDate date];
}




/**
 * @brief The identifier (e.g., folder Id or album Id) from where files must be loaded.
 */
-(id) resourceId{
    return self.uploadFile.syncFileId;
}

/**
 * @brief The folderId in the user's cloud where files are synchronized to.
 */
-(NSString *)targetId{
    return self.uploadFile.udir.repoId;
}

/**
 * @brief The resourceHash in local file system
 */
-(NSString *)resourceHash{
    return [SeafSyncUtils calculateHash:[NSString stringWithFormat:@"%@|%lld",self.resourceId, self.uploadFile.filesize]];
}

/**
 * @brief The SeafSyncSettings Id
 */
-( NSString *)syncSettingId{
    return self.uploadFile.syncId;
}


/**
 * @brief The remoteIdentifier
 */
-(NSString *)remoteIdentifier{
    return self.oid;
}


/**
 * @brief The remoteName
 */
-(NSString *)remoteName{
    return self.uploadFile.name;
}


/**
 * @brief The remotePath
 */
-(NSString *)remotePath{
    return self.uploadFile.udir.path;
}

/**
 * @brief The expiration run date
 */
-(NSDate *) expirationRanOn{
    return nil;
}

@end
