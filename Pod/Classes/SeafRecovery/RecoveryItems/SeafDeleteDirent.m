//
//  SeafDeleteDirent.m
//  Seafile
//
//   Created by Javier Godoy (javigodoy@meytel.net) on 15/12/23.
//

#import "SeafDeleteDirent.h"
#import "ExtentedString.h"
#import "Debug.h"

@interface SeafDeleteDirent ()

@property (nonatomic, retain) id<SeafRecoveryItem> parentDeletion;

@end

@implementation SeafDeleteDirent


/**
 * Initializes a SeafDeleteDirent instance from a dictionary.
 *
 * @param dictionary A dictionary containing data to initialize the object.
 * @return An initialized SeafDeleteDirent object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary andParentDeletion:(id<SeafRecoveryItem>)parentDeletion{
    self = [super init];
    if (self) {
        self.isDir = [dictionary[@"type"] isEqualToString:@"dir"];
        self.objId = dictionary[@"obj_id"];
        self.name = dictionary[@"name"];
        self.parentDir = dictionary[@"parent_dir"];
        self.size = [dictionary[@"size"] integerValue];
        self.parentDeletion = parentDeletion;
        self.recoveryItemType = SeafRecoveryItemTypeDirent;
    }
    return self;
}

/**
 * Creates an array of SeafDeleteDirent objects from an array of dictionaries.
 *
 * @param array An array of dictionaries, each containing data for an object.
 * @return An array of initialized SeafDeleteDirent objects.
 */
+ (NSMutableArray<SeafDeleteDirent *> *)fromArrayDictionary:(NSArray<NSDictionary *> *)array andParentDeletion:(id<SeafRecoveryItem>)parentDeletion{
    NSMutableArray<SeafDeleteDirent *> *items = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:[[SeafDeleteDirent alloc] initWithDictionary:dictionary andParentDeletion:parentDeletion]];
    }];
    
    return items;
}


- (nonnull NSString *)fullPath {
    return [NSString stringWithFormat:@"%@%@",self.path, self.name];
}


- (nonnull NSString *)path {
    return self.parentDir;
}


- (void)recoverUsing:(nonnull SeafConnection *)connection callback:(void (^ _Nullable)(BOOL))callback {
    NSString *requestUrl = [self getRecoverEndpoint];
    
    NSString *form = [NSString stringWithFormat:@"commit_id=%@&p=%@",
                      self.parentDeletion.commitId,
                      [self.fullPath escapedUrl]];
    
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
    NSString *requestUrl = (false == self.isDir) ? @"%@/repos/%@/file/revert/" : @"%@/repos/%@/dir/revert/";
    return [NSString stringWithFormat:requestUrl, API_URL, self.parentDeletion.repositoryId];
}


- (void)revertRecoveryUsing:(nonnull SeafConnection *)connection {
    NSString *requestUrl = [NSString stringWithFormat:API_URL_V21"/repos/%@/file/?p=%@%@", self.parentDeletion.repositoryId, [self.path escapedUrl],[self.name escapedPostForm]];

    [connection sendDelete:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
    }];
}


- (NSInteger)sizeInBytes {
    return self.size;
}

- (NSString *)commitId {
    return self.parentDeletion.commitId;
}


- (NSString *)repositoryId {
   return self.parentDeletion.repositoryId;
}



@end
