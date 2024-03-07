//
//  SeafRecoveryRepositoryProvider.m
//  Seafile
//
//  Created by apps meytel on 18/12/23.
//

#import "SeafRecoveryRepositoryProvider.h"
#import "Debug.h"
#import "ExtentedString.h"
#import "SeafDeletedRepoItem.h"


@interface SeafRecoveryRepositoryProvider ()
@property (nonatomic,retain) SeafConnection *connection;

@end

@implementation SeafRecoveryRepositoryProvider


-(id) initWithConnection:(SeafConnection *) connection{
    self = [super init];
    if(self){
        self.connection = connection;
    }
    
    return self;
}

- (void)getItems:(void (^ _Nullable)(NSArray<id<SeafRecoveryItem>>* items))callback{
    
    NSString *requestUrl = [NSString stringWithFormat:API_URL_V21"/deleted-repos/"];
    
    [self.connection sendRequest:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        callback([SeafDeletedRepoItem fromArrayDictionary:JSON]);
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        Warning("ERROR::deletedRepositories:: resp=%ld\n", (long)response.statusCode);
        callback(@[]);
    }];
    
}
@end
