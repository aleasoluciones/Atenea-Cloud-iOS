//
//  SeafRecoveryFileFolderProvider.m
//  Seafile
//
//  Created by apps meytel on 18/12/23.
//

#import "SeafRecoveryFileFolderProvider.h"

#import "Debug.h"
#import "ExtentedString.h"
#import "SeafDeletedFileFolderItem.h"


@interface SeafRecoveryFileFolderProvider ()
@property (nonatomic,retain) SeafConnection *connection;
@property (nonatomic,retain) NSString *repositoryId;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,retain) NSString *last_scan_stats;

@end

@implementation SeafRecoveryFileFolderProvider


-(id) initWithConnection:(SeafConnection *) connection andRepository:(NSString *) repositoryId andPath:(NSString *) path{
    self = [super init];
    if(self){
        self.connection = connection;
        self.repositoryId = repositoryId;
        self.path = path;
    }
    
    return self;
}


- (void)getItems:(void (^ _Nullable)(NSArray<id<SeafRecoveryItem>>* items))callback{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/repos/%@/trash/?path=%@", API_URL_V21, self.repositoryId, [self.path escapedPostForm]];
    
    if(self.last_scan_stats){
        requestUrl =  [requestUrl stringByAppendingFormat:@"?scan_stat=%@", self.last_scan_stats];
    }
    
    
    [self.connection sendRequest:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        self.last_scan_stats = JSON[@"scan_stat"];
        callback([SeafDeletedFileFolderItem fromArrayDictionary:JSON[@"data"] andRepo:self.repositoryId]);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        Warning("ERROR::getDeletedFilesAndFoldersFrom:: resp=%ld\n", (long)error.localizedDescription);
        callback(@[]);
    }];
   
}



@end
