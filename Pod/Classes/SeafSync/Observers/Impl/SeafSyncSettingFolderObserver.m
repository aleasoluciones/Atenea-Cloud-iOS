//
//  SeafSyncSettingFolderObserver.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 27/9/23.
//

#import "SeafSyncSettingFolderObserver.h"
#import "SeafSyncUtils.h"
#import "SeafSyncTreeBuilder.h"
#import "SeafSyncTree.h"

/**
 This class observes changes in a specific folder defined by SeafSyncSettings.
 */
@interface SeafSyncSettingFolderObserver()

/**
 The SeafSyncSettings associated with the observed folder.
 */
@property (nonatomic, strong) SeafSyncSettings *setting;

/**
 A dictionary containing registered folder observers with their URLs as keys.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, SeafSyncFolderObserver *> *registeredObservers;

@end

@implementation SeafSyncSettingFolderObserver

/**
 Initializes a new instance of SeafSyncSettingFolderObserver with the given SeafSyncSettings.
 @param setting The SeafSyncSettings object specifying the folder to observe.
 @return An initialized instance of SeafSyncSettingFolderObserver.
 */
- (instancetype)initWith:(SeafSyncSettings *)setting {
    self = [super init];
    if (self) {
        self.setting = setting;
        self.registeredObservers = [NSMutableDictionary<NSString *, SeafSyncFolderObserver *> dictionary];
        [self initialize];
    }
    return self;
}

/**
 Initializes the observer by building the tree to observe and creating observers for the tree and its subdirectories.
 */
- (void)initialize {
    SeafSyncTree *tree = [self buildTreeToObserve];
    
    //Tree could be nil if source folder has been deleted from device
    if(tree){
        [self createObserverFor:tree fromSetting:self.setting];
        
        // Subdirectories
        NSArray<id<SeafSyncTreeProtocol>> *foldersItems = [tree getAllChildrensOfType:TreeFolder];
        for (SeafSyncTree *folder in foldersItems) {
            [self createObserverFor:folder fromSetting:self.setting];
        }
    }
}

/**
 Builds the tree structure for the folder to observe.
 @return The SeafSyncTree representing the folder's structure.
 */
- (SeafSyncTree *)buildTreeToObserve {
    NSURL *bookmarkURL = [SeafSyncUtils urlFromBookmark:[self.setting resourceId]];
    
    if (bookmarkURL) {
        SeafSyncTreeBuilder *treeBuilder = [[SeafSyncTreeBuilder alloc] init:bookmarkURL settings:self.setting];
        SeafSyncTree *syncTree = [treeBuilder build];
        return syncTree;
    }
    
    return nil;
}

/**
 Creates an observer for the given folder and adds it to the registeredObservers dictionary.
 @param folder The SeafSyncTree representing the folder to observe.
 @param setting The SeafSyncSettings associated with the folder.
 */
- (void)createObserverFor:(SeafSyncTree *)folder fromSetting:(SeafSyncSettings *)setting {
    SeafSyncFolderObserver *folderObserver = [[SeafSyncFolderObserver alloc] initWith:[folder getURL]];
    [self.registeredObservers setObject:folderObserver forKey:[folder getURL]];
}

/**
 Returns an identifier for the observer based on the associated SeafSyncSettings.
 @return An identifier string.
 */
- (id)observerIdentifier {
    return self.setting.identifier;
}

/**
 Starts observing changes in the registered folders and invokes the callback when changes are detected.
 @param callback A callback block to be executed when changes are detected.
 */
- (void)start:(nullable SeafSyncObserverProtocolCallback)callback {
    // Stop registered observers
    [self stop];
    
    for (SeafSyncFolderObserver *observer in [self.registeredObservers allValues]) {
        [observer start:^(id object) {
            if (callback) {
                callback(self.setting);
            }
        }];
    }
}

/**
 Stops observing changes in the registered folders.
 */
- (void)stop {
    for (SeafSyncFolderObserver *observer in [self.registeredObservers allValues]) {
        [observer stop];
    }
}

@end

