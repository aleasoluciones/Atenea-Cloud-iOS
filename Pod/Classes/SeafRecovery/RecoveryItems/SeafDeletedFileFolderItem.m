//
//  SeafDeletedFileFolderItem.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
//

#import "SeafDeletedFileFolderItem.h"
#import "Debug.h"
#import "ExtentedString.h"
#import "SeafDeleteDirent.h"


@implementation SeafDeletedFileFolderItem 

/**
 * Initializes a SeafDeletedFileFolderItem instance from a dictionary.
 *
 * @param dictionary A dictionary containing data to initialize the object.
 * @return An initialized SeafDeletedFileFolderItem object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary andRepo:(nonnull NSString *)repoId{
    self = [super init];
    if (self) {
        self.commitId = dictionary[@"commit_id"];
        self.deletedTime = dictionary[@"deleted_time"];
        self.isDir = [dictionary[@"is_dir"] boolValue];
        self.objId = dictionary[@"obj_id"];
        self.objName = dictionary[@"obj_name"];
        self.parentDir = dictionary[@"parent_dir"];
        self.scanStat = dictionary[@"scan_stat"];
        self.size = [dictionary[@"size"] integerValue];
        self.repoId = repoId;
        self.recoveryItemType =  SeafRecoveryItemTypeFolder;
    }
    return self;
}

/**
 * Creates an array of SeafDeletedFileFolderItem objects from an array of dictionaries.
 *
 * @param array An array of dictionaries, each containing data for an object.
 * @return An array of initialized SeafDeletedFileFolderItem objects.
 */
+ (NSMutableArray<SeafDeletedFileFolderItem *> *)fromArrayDictionary:(NSArray<NSDictionary *> *)array andRepo:(nonnull NSString *)repoId{
    NSMutableArray<SeafDeletedFileFolderItem *> *items = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:[[SeafDeletedFileFolderItem alloc] initWithDictionary:dictionary andRepo:repoId]];
    }];
    
    return items;
}


//MARK: SeafRecoveryItem
-(NSString *) identifier{
    return self.objId;
}

-(NSString *) name{
    return self.objName;
}

-(NSString *) commit_id {
    return self.commitId;
}

-(NSString *) path{
    return self.parentDir;
}

-(NSString *) deletedDateTime{
    return self.deletedTime;
}

-(SeafRecoveryItemType)itemType{
   return self.isDir ? SeafRecoveryItemTypeFolder : SeafRecoveryItemTypeFile;
}


-(NSString *)fullPath{
    return [NSString stringWithFormat:@"%@%@",self.path, self.name];
}

-(NSInteger)sizeInBytes{
    return self.size;
}

-(NSString *) repositoryId{
    return self.repoId;
}

/**
 Recovers items using the specified Seafile connection.

 This method initiates the recovery process using the provided Seafile connection. Upon completion, the success status is communicated through the provided callback block.

 @param connection The Seafile connection to be used for recovery.
 @param callback A block to be executed upon the completion of the recovery operation. The block takes a single parameter, `success`, indicating whether the recovery was successful or not.

 */
-(void) recoverUsing: (SeafConnection *) connection callback:(void (^ _Nullable)(BOOL success))callback{
    
    NSString *requestUrl = [self getRecoverEndpoint];
    
    NSString *form = [NSString stringWithFormat:@"commit_id=%@&p=%@",
                      self.commit_id,
                      self.fullPath.escapedUrl];
    
    [connection sendPut:requestUrl
                        form:form
                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        callback(TRUE);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        Warning("ERROR::SeafTrashRecoverer->recover:: error=%@\n", error.localizedDescription);
        callback(FALSE);
    }];
}

/**
 *  Returns the recovery endpoint for a recovery item and repository.
 *
 *  @return The recovery endpoint URL.
 */
-(NSString *) getRecoverEndpoint  {
    NSString *requestUrl = (self.itemType == SeafRecoveryItemTypeFile) ? @"%@/repos/%@/file/revert/" : @"%@/repos/%@/dir/revert/";
    return [NSString stringWithFormat:requestUrl, API_URL, self.repositoryId];
}

/**
 Reverts the recovery operation using the specified Seafile connection.

 This method sends a DELETE request to revert the recovery operation for the associated repository using the provided Seafile connection.

 @param connection The Seafile connection to be used for reverting the recovery operation.

 */
-(void) revertRecoveryUsing:(SeafConnection *)connection{
 
    NSString *requestUrl = [NSString stringWithFormat:API_URL_V21"/repos/%@/file/?p=%@%@", self.repositoryId, [self.path escapedUrl],[self.name escapedPostForm]];

    [connection sendDelete:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
    }];
}



//MARK: SeafRecoveryProviderProtocol
- (void)getRecoverableItems:(nonnull SeafConnection *)connection callback:(void (^ _Nullable)(NSArray<id<SeafRecoveryItem>> * _Nonnull))items {
    NSString *requestUrl = [NSString stringWithFormat:@"%@/repos/%@/commits/%@/dir/?path=%@", API_URL_V21, self.repoId,self.commit_id, [self.fullPath escapedPostForm]];
    
    [connection sendRequest:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        items([SeafDeleteDirent fromArrayDictionary:JSON[@"dirent_list"] andParentDeletion:self]);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        Warning("ERROR::getRecoverableItems:: resp=%ld\n", (long)error.localizedDescription);
        items(@[]);
    }];
}

@end
