//
//  SeafSyncFileItem.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 23/9/18.
//

#import "SeafSyncFileItem.h"
#import "SeafSyncUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation SeafSyncFileItem

@synthesize path;
@synthesize creationDate;
@synthesize addedToDirectoryDate;
@synthesize itemType;
@synthesize isDirectory;
@synthesize sizeInBytes;
@synthesize fileHash;
@synthesize identifier;
@synthesize fileType;
@synthesize extension;
@synthesize fileName;

/**
 Initializes a `SeafSyncFileItem` object with the specified path URL.
 
 @param path The URL of the file path.
 @return An initialized instance of `SeafSyncFileItem`.
 */
- (id)initWithPath:(NSURL *)path {
    self = [super init];
    if (self) {
        self.path = path;
        [self fillProperties];
    }
    
    return self;
}

/**
 Fills the properties of the `SeafSyncFileItem` object with file information.
 */
- (void)fillProperties {
    
    if ([[NSFileManager defaultManager] ubiquityIdentityToken]) {
       
        [self.path startAccessingSecurityScopedResource];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[self.path relativePath] error:nil];
        NSDictionary *resourceValues = [self.path resourceValuesForKeys:@[NSURLDocumentIdentifierKey, NSURLAddedToDirectoryDateKey,NSURLIsDirectoryKey] error:nil];
        
        if (fileAttributes) {
            // Resources
            self.extension = [[self.path pathExtension] lowercaseString];
            self.fileName = [self.path lastPathComponent];
            self.identifier = [[resourceValues objectForKey:NSURLDocumentIdentifierKey] stringValue];
            self.addedToDirectoryDate = [resourceValues objectForKey:NSURLAddedToDirectoryDateKey];
            self.isDirectory = [[resourceValues objectForKey:NSURLIsDirectoryKey] boolValue];
            self.itemType = (self.isDirectory)? SeafSyncItemTypeFolder : SeafSyncItemTypeFile;
            
            // Attributes
            self.sizeInBytes = [[fileAttributes objectForKey:NSFileSize] longLongValue];
            self.creationDate = [fileAttributes objectForKey:NSFileCreationDate];

            // Custom
            self.fileHash = [SeafSyncUtils calculateHash:[NSString stringWithFormat:@"%@,%lld", self.identifier, self.sizeInBytes]];
            
            [self setFileType];
        }

        [self.path stopAccessingSecurityScopedResource];
    }
}

/**
 Sets the file type based on the media type of the file.
 */
-(void)setFileType {
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:[self.path filePathURL]];

    // Check if the URL points to a video resource
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
        self.fileType = SeafSyncItemFileTypeVideo;
        return;
    }

    // Check if the URL points to an audio resource
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
        self.fileType = SeafSyncItemFileTypeAudio;
        return;
    }

    // Check if the URL points to an image resource
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.path filePathURL]]];
    if (image) {
        self.fileType = SeafSyncItemFileTypeImage;
        return;
    }

    // Default to other if not recognized
    self.fileType = SeafSyncItemFileTypeOther;
}

@end

