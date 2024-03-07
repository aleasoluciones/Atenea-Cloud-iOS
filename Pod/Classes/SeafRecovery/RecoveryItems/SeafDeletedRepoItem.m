//
//  SeafDeletedRepoItem.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
//

#import "SeafDeletedRepoItem.h"
#import "Debug.h"
#import "ExtentedString.h"


@implementation SeafDeletedRepoItem


/**
 * Creates an array of SeafDeletedRepoItem objects from an array of dictionaries.
 *
 * @param array An array of dictionaries, each containing data for an object.
 * @return An array of initialized SeafDeletedRepoItem objects.
 */
+ (NSMutableArray<SeafDeletedRepoItem *> *)fromArrayDictionary:(NSArray<NSDictionary *> *)array {
    NSMutableArray<SeafDeletedRepoItem *> *items = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:[[SeafDeletedRepoItem alloc] initWithDictionary:dictionary]];
    }];
    
    return items;
}

/**
 * Initializes a SeafDeletedRepoItem instance from a dictionary.
 *
 * @param dictionary A dictionary containing data to initialize the object.
 * @return An initialized SeafDeletedRepoItem object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _delTime = dictionary[@"del_time"];
        _encrypted = [dictionary[@"encrypted"] integerValue];
        _headCommitId = dictionary[@"head_commit_id"];
        _orgId = dictionary[@"org_id"];
        _ownerContactEmail = dictionary[@"owner_contact_email"];
        _ownerEmail = dictionary[@"owner_email"];
        _ownerName = dictionary[@"owner_name"];
        _repoId = dictionary[@"repo_id"];
        _repoName = dictionary[@"repo_name"];
        _size = [dictionary[@"size"] integerValue];
        _recoveryItemType = SeafRecoveryItemTypeRepository;
        
    }
    return self;
}


//MARK: SeafRecoveryItem
-(NSString *) identifier{
    return self.orgId;
}

-(NSString *) name{
    return self.repoName;
}

-(NSString *) commit_id {
    return self.headCommitId;
}

-(NSString *) path{
    return @"";
}

-(NSString *) deletedDateTime{
    return self.delTime;
}
-(SeafRecoveryItemType)itemType{
    return SeafRecoveryItemTypeRepository;
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

-(BOOL) isDir{
    return FALSE;
}

-(NSString *) commitId{
    return self.headCommitId;
}

/**
 Recovers items using the specified Seafile connection.

 This method initiates the recovery process using the provided Seafile connection. Upon completion, the success status is communicated through the provided callback block.

 @param connection The Seafile connection to be used for recovery.
 @param callback A block to be executed upon the completion of the recovery operation. The block takes a single parameter, `success`, indicating whether the recovery was successful or not.

 */
-(void) recoverUsing: (SeafConnection *) connection callback:(void (^ _Nullable)(BOOL success))callback{
    NSString *requestUrl = [NSString stringWithFormat:API_URL_V21"/deleted-repos/"];
    
    NSString *form = [NSString stringWithFormat:@"repo_id=%@",self.repositoryId];
    
    [connection sendPost:requestUrl
                        form:form
                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        callback(TRUE);

    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        Warning("ERROR::recoveryRepository->recover:: error=%@\n", error.localizedDescription);
        callback(FALSE);
    }];
}

/**
 Reverts the recovery operation using the specified Seafile connection.

 This method sends a DELETE request to revert the recovery operation for the associated repository using the provided Seafile connection.

 @param connection The Seafile connection to be used for reverting the recovery operation.

 */
-(void) revertRecoveryUsing:(SeafConnection *)connection{
    NSString *requestUrl = [NSString stringWithFormat:API_URL"/repos/%@/", self.repositoryId];
    [connection sendDelete:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
    }];
}

@end
