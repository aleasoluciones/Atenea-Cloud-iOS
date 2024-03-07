//
//  SeafThumbnailProvider.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
//

#import "SeafThumbnailLoader.h"
#import "Debug.h"
#import "SeafStorage.h"

@interface SeafThumbnailLoader ()

@property SeafConnection *connection;

@end

@implementation SeafThumbnailLoader

/**
 * Initializes a new instance of the SeafThumbnailLoader class.
 * @param connection The SeafConnection object associated with the loader.
 * @return An initialized SeafThumbnailLoader object.
 */
- (id)initWithConnection:(SeafConnection *)connection {
    self = [super init];
    if (self) {
        self.connection = connection;
    }
    return self;
}

/**
 * Loads a thumbnail for a file in the specified repository and path.
 * @param repoId The ID of the repository.
 * @param path The path of the file in the repository.
 * @param size The desired size of the thumbnail.
 * @param onCompleted A block to be executed upon completion, providing the loaded UIImage.
 */
- (void)load:(NSString *)repoId
      andPath:(NSString *)path
      andSize:(long)size
  onCompleted:(void (^)(UIImage *image))onCompleted {
    
    NSString *cachedPath = [self createPathFrom:repoId andPath:path andSize:size];
    
    if ([self existsCachedVersion:cachedPath]) {
        onCompleted([self imageFromURL:cachedPath]);
        return;
    }
    
    [self loadFromRemoteSource:repoId andPath:path andSize:size onCompleted:onCompleted];
}

/**
 * Creates a UIImage from the specified image source URL.
 * @param imageSource The URL of the image source.
 * @return A UIImage object created from the image source.
 */
- (UIImage *)imageFromURL:(NSString *)imageSource {
    return [UIImage imageWithData:[self getCachedVersion:imageSource]];
}

/**
 * Loads the thumbnail from the remote source using the specified repository ID, file path, and size.
 * @param repoId The ID of the repository.
 * @param path The path of the file in the repository.
 * @param size The desired size of the thumbnail.
 * @param onCompleted A block to be executed upon completion, providing the loaded UIImage.
 */
- (void)loadFromRemoteSource:(NSString *)repoId
                    andPath:(NSString *)path
                    andSize:(long)size
                onCompleted:(void (^)(UIImage *image))onCompleted {
    
    NSString *thumburl = [NSString stringWithFormat:@"%@/repos/%@/thumbnail/?size=%ld&p=%@", API_URL, repoId, size, path];
    NSURLRequest *downloadRequest = [self.connection buildRequest:thumburl method:@"GET" form:nil];
    NSString *target = [self createPathFrom:repoId andPath:path andSize:size];
    
    NSURLSessionDownloadTask *_thumbtask = [self.connection.sessionMgr downloadTaskWithRequest:downloadRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:target];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (!error) {
            if ([[NSFileManager defaultManager] moveItemAtPath:filePath.path toPath:target error:nil]) {
                onCompleted([self imageFromURL:filePath.path]);
            }
            return;
        }
        
        Debug("Failed to download thumb, error=%@", error.localizedDescription);
        
    }];
    
    [_thumbtask resume];
}

/**
 * Creates a path for the cached version based on the repository ID, file path, and size.
 * @param repoId The ID of the repository.
 * @param path The path of the file in the repository.
 * @param size The desired size of the thumbnail.
 * @return A path for the cached version.
 */
- (NSString *)createPathFrom:(NSString *)repoId
                    andPath:(NSString *)path
                    andSize:(long)size {
    return [NSString stringWithFormat:@"%@_%@-%ld.tmp", repoId, path, size];
}

/**
 * Stores the cached version of the file at the specified path.
 * @param filePath The URL of the file to be cached.
 * @param path The path for the cached version.
 * @return YES if storing the cached version is successful, otherwise NO.
 */
- (BOOL)storeCachedVersionOf:(NSURL *)filePath
                    intoPath:(NSString *)path {
    NSString *cachedPath = [self cachedPathFor:path];
    return [[NSFileManager defaultManager] moveItemAtPath:filePath.path toPath:cachedPath error:nil];
}

/**
 * Checks if a cached version exists at the specified path.
 * @param path The path to check for a cached version.
 * @return YES if a cached version exists, otherwise NO.
 */
- (BOOL)existsCachedVersion:(NSString *)path {
    NSString *cachedPath = [self cachedPathFor:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:cachedPath];
}

/**
 * Retrieves the cached version of the file at the specified path.
 * @param path The path of the cached version.
 * @return NSData containing the contents of the cached version.
 */
- (NSData *)getCachedVersion:(NSString *)path {
    NSString *cachedPath = [self cachedPathFor:path];
    return [NSData dataWithContentsOfFile:cachedPath];
}

/**
 * Generates the full cached path for the specified path.
 * @param path The path for which to generate the cached path.
 * @return The full cached path.
 */
- (NSString *)cachedPathFor:(NSString *)path {
    return [SeafStorage.sharedObject.thumbsDir stringByAppendingPathComponent:path];
}

@end
