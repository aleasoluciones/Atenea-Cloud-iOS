//
//  SeafSyncFolderStateService.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 25/9/23.
//

#import "SeafSyncFolderStateService.h"
#import "SeafSyncTreeFolderStateRepository.h"
#import "SeafSyncTreeFolderStateCoreDataRepository.h"
#import "SeafSyncTreeState.h"
#import "SeafSyncTreeChangeDetector.h"

/**
 `SeafSyncFolderStateService` is a service class for managing synchronization folder states.
 */
@interface SeafSyncFolderStateService()

/**
 The repository responsible for managing synchronization folder states.
 */
@property (nonatomic, retain) id<SeafSyncTreeFolderStateRepository> repository;

/**
 The change detector for tracking changes in synchronization folder states.
 */
@property (nonatomic, retain) SeafSyncTreeChangeDetector *changeDetector;

@end

@implementation SeafSyncFolderStateService

#pragma mark - Initialization

/**
 Initializes an instance of `SeafSyncFolderStateService` with the default repository.

 @return An initialized instance of `SeafSyncFolderStateService`.
 */
-(instancetype)init {
    return [self initWith:[[SeafSyncTreeFolderStateCoreDataRepository alloc] init]];
}

/**
 Initializes an instance of `SeafSyncFolderStateService` with a specified repository.

 @param repository The repository for managing synchronization folder states.
 @return An initialized instance of `SeafSyncFolderStateService`.
 */
-(instancetype)initWith:(id<SeafSyncTreeFolderStateRepository>)repository {
    self = [super init];
    if(self) {
        self.repository = repository;
    }
    return self;
}

#pragma mark - CRUD Methods

/**
 Inserts a new synchronization tree state.

 @param state The synchronization tree state to insert.
 */
-(void)insert:(SeafSyncTreeState *)state {
    return [self.repository insert:state];
}

/**
 Updates an existing synchronization tree state.

 @param state The synchronization tree state to update.
 */
-(void)update:(SeafSyncTreeState *)state {
    return [self.repository update:state];
}

/**
 Removes an existing synchronization tree state.

 @param state The synchronization tree state to remove.
 */
-(void)remove:(SeafSyncTreeState *)state {
    return [self.repository remove:state];
}

/**
 Retrieves all synchronization tree states.

 @return An array containing all synchronization tree states.
 */
-(NSMutableArray<SeafSyncTreeState *> *)all {
    return [self.repository all];
}

/**
 Clears all synchronization tree states.
 */
-(void)clear {
    return [self.repository clear];
}

#pragma mark - Find Methods

/**
 Finds synchronization tree states based on a specified URL.

 @param url The URL used for filtering.
 @return An array containing synchronization tree states that match the specified URL.
 */
-(NSArray<SeafSyncTreeState *> *)findByURL:(NSURL *)url {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"folderUrl == %@", url];
    return [self.repository find:predicate];
}

/**
 Finds synchronization tree states based on a specified sync setting ID.

 @param syncSettingId The sync setting ID used for filtering.
 @return An array containing synchronization tree states that match the specified sync setting ID.
 */
-(NSArray<SeafSyncTreeState *> *)findBySyncSetting:(NSString *)syncSettingId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncSettingId == %@", syncSettingId];
    return [self.repository find:predicate];
}

/**
 Finds synchronization tree states based on a specified predicate.

 @param predicate The predicate used for filtering.
 @return An array containing synchronization tree states that match the specified predicate.
 */
-(NSArray<SeafSyncTreeState *> *)find:(NSPredicate *)predicate {
    return [self.repository find:predicate];
}

@end
