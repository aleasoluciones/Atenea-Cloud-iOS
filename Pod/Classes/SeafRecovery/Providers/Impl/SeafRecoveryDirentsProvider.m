//
//  SeafRecoveryDirentsProvider.m
//  Seafile
//
//  Created by apps meytel on 18/12/23.
//

#import "SeafRecoveryDirentsProvider.h"
#import "Debug.h"
#import "ExtentedString.h"
#import "SeafDeleteDirent.h"

@interface SeafRecoveryDirentsProvider ()

@property (nonatomic, retain) id<SeafRecoveryItem> parentDeletion;
@property (nonatomic,retain) SeafConnection *connection;

@end

@implementation SeafRecoveryDirentsProvider

-(id) initWithConnection:(SeafConnection *) connection andParentDeletion:(id<SeafRecoveryItem>) parentDeletion {
    self = [super init];
    if(self){
        self.connection = connection;
        self.parentDeletion = parentDeletion;
    }
    
    return self;
}

- (void)getItems:(void (^ _Nullable)(NSArray<id<SeafRecoveryItem>>* items))callback{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/repos/%@/commits/%@/dir/?path=%@", API_URL_V21, self.parentDeletion.repositoryId,self.parentDeletion.commitId, [self.parentDeletion.fullPath escapedPostForm]];
    
    [self.connection sendRequest:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        callback([SeafDeleteDirent fromArrayDictionary:JSON[@"dirent_list"] andParentDeletion:self.parentDeletion]);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        Warning("ERROR::getRecoverableItems:: resp=%ld\n", (long)error.localizedDescription);
        callback(@[]);
    }];
}


@end
