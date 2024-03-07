/**
 * @file SeafSyncTreeChangeDetector.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncTreeChangeDetector class.
 *
 * This file contains the implementation of the SeafSyncTreeChangeDetector class, which detects changes in synchronization trees.
 */

#import "SeafSyncTreeChangeDetector.h"
#import "SeafSyncTree.h"
#import "SeafSyncTreeState.h"
#import "SeafSyncFolderStateService.h"

@interface SeafSyncTreeChangeDetector ()

@property (nonatomic, strong) SeafSyncTree *tree;
@property (nonatomic, strong) SeafSyncFolderStateService *stateService;

@end

@implementation SeafSyncTreeChangeDetector

/**
 * Initializes an instance of SeafSyncTreeChangeDetector with default state service.
 *
 * @return An instance of SeafSyncTreeChangeDetector.
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.stateService = [[SeafSyncFolderStateService alloc] init];
    }
    return self;
}

/**
 * Detects changes in a synchronization tree since the last synchronization.
 *
 * @param tree The SeafSyncTree to check for changes.
 * @return A SeafSyncTree object representing the changes since the last synchronization.
 */
- (SeafSyncTree *)changes:(SeafSyncTree *)tree {
    // Retrieve all stored folder statuses from the last synchronization
    NSArray<SeafSyncTreeState *> *storedStates = [self.stateService findBySyncSetting:[tree getSyncSettingId]];
    
    // Call the detectChanges method to perform the change detection
    return [self detectChanges:tree lastStates:storedStates];
}

/**
 * Recursively detects changes in a synchronization tree.
 *
 * @param tree The SeafSyncTree to check for changes.
 * @param storedStates An array of SeafSyncTreeState objects representing the last known states.
 * @return A SeafSyncTree object representing the changes.
 */
- (SeafSyncTree *)detectChanges:(SeafSyncTree *)tree lastStates:(NSArray<SeafSyncTreeState *> *)storedStates {
    SeafSyncTree *treeWithChangedFolderOnly = [tree copy];
    [treeWithChangedFolderOnly clearChildrens];
    
    SeafSyncTreeState *matchingState = [self findMatching:tree in:storedStates];
    
    // If there's no previous state for this folder, it means it didn't exist previously
    if (matchingState == nil) {
        return tree;
    }
    
    // If fullHash values are the same, it means there are no changes in the entire children tree,
    // so this node should not be appended to changed nodes
    if ([[matchingState getFullHash] isEqualToString:[tree getFullHash]]) {
        return nil;
    }
    
    for (SeafSyncTree *children in [tree getChildrens]) {
        SeafSyncTree *changedChildren = [self detectChanges:children lastStates:storedStates];
        if (changedChildren != nil) {
            [treeWithChangedFolderOnly addChildren:changedChildren];
        }
    }
    
    return treeWithChangedFolderOnly;
}

/**
 * Finds a matching state for a given tree node within an array of stored states.
 *
 * @param treeNode The SeafSyncTree node to find a matching state for.
 * @param storedStates An array of SeafSyncTreeState objects representing the last known states.
 * @return A SeafSyncTreeState object representing the matching state, or nil if no match is found.
 */
- (SeafSyncTreeState *)findMatching:(SeafSyncTree *)treeNode in:(NSArray<SeafSyncTreeState *> *)storedStates {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafSyncTreeState *state, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [[state getSyncSettingId] isEqualToString:[treeNode getSyncSettingId]] &&
               [[[state getURL] absoluteString] isEqualToString:[[treeNode getURL] absoluteString]];
    }];
    
    NSArray *filteredArray = [storedStates filteredArrayUsingPredicate:predicate];
    return [filteredArray firstObject];
}

@end

