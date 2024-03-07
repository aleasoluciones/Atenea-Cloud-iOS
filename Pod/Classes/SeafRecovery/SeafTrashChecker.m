//
//  SeafTrashChecker.m
//  Seafile
//
//  Created by apps meytel on 3/1/24.
//

#import "SeafTrashChecker.h"


@interface SeafTrashChecker ()

@property id<SeafRecoveryItemsProvider> provider;

@end


@implementation SeafTrashChecker

/**
 *  Initializes a SeafTrashChecker object with a connection.
 *  @param provider The SeafRecoveryItemsProvider implementation
 *  @return A SeafTrashChecker object.
 */
- (id) initWithProvider:(id<SeafRecoveryItemsProvider>) provider{
    self = [super init];
    if(self) {
        self.provider = provider;
    }
    return self;
}



- (void) existsInTrash:(NSString *) path callback:(void (^ _Nullable)(BOOL exists))callback{
    
    [self.provider getItems:^(NSArray<id<SeafRecoveryItem>> * _Nonnull items) {
        __block BOOL exists = FALSE;
        
        [items enumerateObjectsUsingBlock:^(id<SeafRecoveryItem>  _Nonnull itemInTrash, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemInTrash.fullPath isEqualToString:path]){
                exists = TRUE;
                *stop = TRUE;
            }
        }];
        
        callback(exists);

    }];
}


- (void) existsAnyInTrash:(NSArray<NSString *> *) paths callback:(void (^ _Nullable)(BOOL exists))callback{
    
    [self.provider getItems:^(NSArray<id<SeafRecoveryItem>> * _Nonnull items) {
        __block BOOL exists = FALSE;
        
        [items enumerateObjectsUsingBlock:^(id<SeafRecoveryItem>  _Nonnull itemInTrash, NSUInteger idx, BOOL * _Nonnull stop) {
            [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([itemInTrash.fullPath isEqualToString:path]){
                    exists = TRUE;
                    *stop = TRUE;
                }
            }];
            
            if(exists){
                *stop = TRUE;
            }
        }];
        
        callback(exists);

    }];
}


@end
