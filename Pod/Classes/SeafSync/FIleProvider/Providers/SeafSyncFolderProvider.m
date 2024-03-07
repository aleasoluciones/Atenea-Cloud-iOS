//
//  SeafSyncFolderProvider.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/9/23.
//

#import "SeafSyncFolderProvider.h"
#import "SeafSyncFileItem.h"
#import "SeafSyncSettings.h"

/**
 * SeafSyncFolderProvider ()
 * @brief Private interface for SeafSyncFolderProvider.
 */
@interface SeafSyncFolderProvider ()

/**
 * The folder URL for synchronization.
 */
@property (nonatomic, retain) NSURL *folderURL;

/**
 * The SeafSyncSettings for synchronization.
 */
@property (nonatomic, strong) SeafSyncSettings *settings;


@end

@implementation SeafSyncFolderProvider

/**
 * Initializes a new instance of SeafSyncFolderProvider with the specified folder URL.
 * @param folderURL The folder URL for synchronization.
 * @return An initialized instance of SeafSyncFolderProvider.
 */
- (id)initWithFolderURL:(NSURL *)folderURL {
    self = [super init];
    if (self) {
        self.folderURL = folderURL;
    }
    return self;
}

/**
 * Gets the list of files in the synchronized folder.
 * @param onError An optional error pointer.
 * @return An array of SeafSyncFileItem objects representing the files in the folder.
 */
- (NSMutableArray<SeafSyncFileItem *> *)getFiles:(NSError **)onError {
    NSMutableArray<SeafSyncFileItem *> *files = [[NSMutableArray<SeafSyncFileItem *> alloc] init];
    NSError *error;
    
    // No Folder URL, return empty array
    if (self.folderURL == nil) {
        return files;
    }
    
    if ([[NSFileManager defaultManager] ubiquityIdentityToken]) {
        [self.folderURL startAccessingSecurityScopedResource];
        
        // Read the contents from the bookmark URL
        NSArray<NSURL *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.folderURL includingPropertiesForKeys:@[NSURLAddedToDirectoryDateKey, NSURLDocumentIdentifierKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
        
        // Iterate through files and folders in the directory
        [contents enumerateObjectsUsingBlock:^(NSURL * _Nonnull content, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // Grant access to the protected object
            [content startAccessingSecurityScopedResource];
            
            [files addObject:[[SeafSyncFileItem alloc] initWithPath:content]];
            
            // Stop granted access to the protected object
            [content stopAccessingSecurityScopedResource];
        }];
        
        // Release the security scope.
        [self.folderURL stopAccessingSecurityScopedResource];
    }
    
    return files;
}

@end

