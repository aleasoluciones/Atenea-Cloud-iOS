/**
 * @file SeafSyncTreeBuilder.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncTreeBuilder class.
 *
 * This file contains the implementation of the SeafSyncTreeBuilder class, which is used to build synchronized tree structures.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncTreeBuilder.h"
#import "SeafSyncEnums.h"
#import "SeafUploadFile.h"
#import "SeafDir.h"
#import "SeafSyncProviderProtocol.h"
#import "SeafSyncItemProtocol.h"
#import "SeafSyncFileProviderFactory.h"

@interface SeafSyncTreeBuilder()

@property (nonatomic, strong) SeafSyncTree *root;
@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, strong) SeafSyncSettings *settings;


@end

@implementation SeafSyncTreeBuilder

/**
 * Initializes an instance of SeafSyncTreeBuilder with a source URL and synchronization settings.
 *
 * @param sourceURL The source URL for the tree structure.
 * @param settings The synchronization settings to use.
 * @return An instance of SeafSyncTreeBuilder.
 */
- (instancetype)init:(NSURL *)sourceURL settings:(SeafSyncSettings *)settings {
    self = [super init];
    if (self) {
        self.root = [[SeafSyncTree alloc] init];
        self.sourceURL = sourceURL;
        self.settings = settings;
    }
    return self;
}

/**
 * Builds a synchronized tree structure.
 *
 * @return A SeafSyncTree object representing the synchronized tree.
 */
- (SeafSyncTree *)build {
    self.root = [[SeafSyncTree alloc] init];
    [self.root setURL:self.sourceURL];
    [self.root setSyncSettingId:[self.settings identifier]];
    [self readContentsRecursivelyFrom:self.sourceURL parentNode:self.root];
    return self.root;
}

/**
 * Recursively reads contents from a URL and constructs a synchronization tree.
 *
 * @param folderURL The URL of the folder to read.
 * @param parent The parent node in the tree structure.
 * @return The parent node with its children nodes added to the tree.
 */
- (SeafSyncTree *)readContentsRecursivelyFrom:(NSURL *)folderURL parentNode:(SeafSyncTree *)parent {
    
    id<SeafSyncProviderProtocol> fileProvider = [SeafSyncFileProviderFactory getProviderForURL:folderURL withSettings:self.settings];

    NSMutableArray<id<SeafSyncItemProtocol>> *items =  [fileProvider getFiles:nil];
    
    [items enumerateObjectsUsingBlock:^(id<SeafSyncItemProtocol>  _Nonnull syncItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (syncItem.isDirectory) {
            [parent addChildren:[self readContentsRecursivelyFrom:syncItem.path parentNode:[self createTreeNodeWith:syncItem ofType:TreeFolder]]];
        } else {  // Is a file
            [parent addChildren:[self createTreeNodeWith:syncItem ofType:TreeFile]];
            
        }
    }];
    
    return parent;

}


/**
 * Creates a SeafSyncTree node with a URL and type.
 *
 * @param syncItem The URL for the tree node.
 * @param type The type of the tree node (TreeFolder or TreeFile).
 * @return A SeafSyncTree node.
 */
- (SeafSyncTree *)createTreeNodeWith:(id<SeafSyncItemProtocol>) syncItem ofType:(SyncTreeType)type{
    SeafSyncTree *node = [[SeafSyncTree alloc] init];
    [node setURL:syncItem.path];
    [node setId:syncItem.identifier];
    [node setType: type];
    [node setSizeInBytes:syncItem.sizeInBytes];
    [node setSyncSettingId:self.settings.identifier];
    return node;
}



/**
 * Checks if a NSURL represents a directory.
 *
 * @param contentURL The URL to check.
 * @return YES if the URL represents a directory, NO otherwise.
 */
- (BOOL)isDirectory:(NSURL *)contentURL {
    NSNumber *isDirectory;
    [contentURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    return [isDirectory boolValue];
}

/**
 * Creates a SeafDir object from a NSURL.
 *
 * @param fromURL The URL to create the SeafDir from.
 * @return A SeafDir object.
 */
- (SeafDir *)createUploadDirectory:(NSURL *)fromURL {
    SeafDir *uploadDirectory = [[SeafDir alloc] init];
    return uploadDirectory;
}

/**
 * Gets the internal file resource identifier from a NSURL.
 *
 * @param content The URL to extract the identifier from.
 * @return The extracted identifier as a string.
 */
- (NSString *)getIitemIdentifier:(NSURL *)content {
    NSString *itemIdentifier;
    [content getResourceValue:&itemIdentifier forKey:NSURLDocumentIdentifierKey error:nil];
    return [itemIdentifier stringValue];
}

@end

