/**
 * @file SeafSyncTreeService.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncTreeService class.
 *
 * This file contains the implementation of the SeafSyncTreeService class, which manages synchronization trees.
 */

#import "SeafSyncTreeService.h"
#import "SeafSyncTreeBuilder.h"
#import "SeafSyncTreeProtocol.h"
#import "SeafSyncSettings.h"

@interface SeafSyncTreeService()

@property (nonatomic, strong) SeafSyncFolderStateService *stateService;
@property (nonatomic, strong) SeafSyncTreeChangeDetector *changeDetector;

@end

@implementation SeafSyncTreeService

/**
 * Initializes an instance of SeafSyncTreeService with default state service and change detector.
 *
 * @return An instance of SeafSyncTreeService.
 */
- (instancetype)init {
    return [self initWith:[[SeafSyncFolderStateService alloc] init] changeDetector:[[SeafSyncTreeChangeDetector alloc] init]];
}

/**
 * Initializes an instance of SeafSyncTreeService with custom state service and change detector.
 *
 * @param stateService The synchronization folder state service to use.
 * @param changeDetector The synchronization tree change detector to use.
 * @return An instance of SeafSyncTreeService.
 */
- (instancetype)initWith:(SeafSyncFolderStateService *)stateService changeDetector:(SeafSyncTreeChangeDetector *)changeDetector {
    self = [super init];
    if (self) {
        self.stateService = stateService;
        self.changeDetector = changeDetector;
    }
    return self;
}

/**
 * Saves the state of a SeafSyncTree and its child tree nodes
 *
 * @param tree The SeafSyncTree to save.
 */
- (void)saveTreeRecursively:(SeafSyncTree *)tree {
   
    [self saveTree:tree];
    
    // Iterate through children
    for (SeafSyncTree *childTree in [tree getChildrens]) {
        [self saveTree:childTree];
    }
}

/**
 * Saves the state of a SeafSyncTree.
 *
 * @param tree The SeafSyncTree to save.
 */
- (void)saveTree:(SeafSyncTree *)tree {
    // Only save folder status
    if ([tree getType] != TreeFolder && [tree getType] != TreeRoot) return;
    
    // Create SeafSyncTreeState from the tree's state
    SeafSyncTreeState *state = [[SeafSyncTreeState alloc] init];
    [state setId:[[tree getURL] absoluteString]];
    [state setRelativeHash:[tree getRelativeHash]];
    [state setFullHash:[tree getFullHash]];
    [state setURL:[tree getURL]];
    [state setSyncSettingId:[tree getSyncSettingId]];
    [state setType:[tree getType]];
    
    [self.stateService insert:state];
    
}


/**
 * Detects changes in a SeafSyncTree since the last synchronization.
 *
 * @param tree The SeafSyncTree to check for changes.
 * @return A SeafSyncTree object representing the changes since the last synchronization.
 */
- (SeafSyncTree *)changesSinceLastSyncFor:(SeafSyncTree *)tree {
    return [self.changeDetector changes:tree];
}

/**
 * Builds a SeafSyncTree from a URL and settings.
 *
 * @param url The URL for the tree structure.
 * @param settings The synchronization settings to use.
 * @return A SeafSyncTree object representing the synchronization tree.
 */
- (SeafSyncTree *)buildFrom:(NSURL *)url settings:(SeafSyncSettings *)settings {
    SeafSyncTreeBuilder *treeBuilder = [[SeafSyncTreeBuilder alloc] init:url settings:settings];
    return [treeBuilder build];
}

@end

