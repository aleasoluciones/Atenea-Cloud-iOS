//
//  SeafSyncGalleryProvider.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import "SeafSyncGalleryProvider.h"
#import "SeafSyncAssetItem.h"
#import <Photos/Photos.h>
#import "SeafPhotoAsset.h"
#import <Photos/Photos.h>

/**
 *  SeafSyncGalleryProvider ()
 * @brief Private interface for SeafSyncGalleryProvider.
 */
@interface SeafSyncGalleryProvider()

/**
 * The name of the album to synchronize.
 */
@property (nonatomic, retain) NSString *albumName;

@end

@implementation SeafSyncGalleryProvider

/**
 * Initializes a new instance of SeafSyncGalleryProvider with the specified album name.
 * @param albumName The name of the gallery or album to synchronize.
 * @return An initialized instance of SeafSyncGalleryProvider.
 */
- (id)initWithAlbumName:(NSString *)albumName {
    self = [super init];
    if (self) {
        self.albumName = albumName;
    }
    return self;
}

/**
 * Gets the list of assets in the synchronized gallery or album.
 * @param onError An optional error pointer.
 * @return An array of SeafSyncAssetItem objects representing the assets in the gallery or album.
 */
- (NSMutableArray<SeafSyncAssetItem *> *)getFiles:(NSError **)onError {
    PHFetchResult *assets;
    
    //No gallery access. Return empty array.
    if([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized){
        return [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    
    
    if (self.albumName == nil) {
        assets = [self readAssetsFromCameraRoll];
    } else {
        assets = [self readAssetsFromAlbum];
    }
    
    if(assets == nil){
        *onError = [self createErrorResponse:@"Album or Gallery not found"];
    }
    
    return [self createSeafPhotoAssetsFromResult:assets];
}

/**
 * Iterates through assets in the gallery and processes them.
 * @param fetchResult The fetch result containing the assets.
 * @return An array of SeafSyncAssetItem objects representing the processed assets.
 */
- (NSMutableArray<SeafSyncAssetItem *> *)createSeafPhotoAssetsFromResult:(PHFetchResult *)fetchResult {
    NSMutableArray<SeafSyncAssetItem *> *files = [[NSMutableArray<SeafSyncAssetItem *> alloc] init];

    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [files addObject:[[SeafSyncAssetItem alloc] initWithPHAsset:asset]];
    }];

    return files;
}

/**
 * Sets default PHFetchOptions for requesting assets.
 * @return The default PHFetchOptions.
 */
- (PHFetchOptions *)defaultFetchOptions {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];

    return fetchOptions;
}

/**
 * Reads assets from the Camera Roll.
 * @return The fetch result containing the assets from the Camera Roll.
 */
- (PHFetchResult *)readAssetsFromCameraRoll {
    PHFetchResult *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    return [PHAsset fetchAssetsInAssetCollection:[cameraRoll firstObject] options:[self defaultFetchOptions]];
}

/**
 * Reads assets from a specific album.
 * @return The fetch result containing the assets from the specified album.
 */
- (PHFetchResult *)readAssetsFromAlbum {
    PHAssetCollection *album = [self findAlbum];
    if (album != nil) {
        return [PHAsset fetchAssetsInAssetCollection:album options:[self defaultFetchOptions]];
    }
    
    return nil;
}

/**
 * Finds a specific album by name.
 * @return The PHAssetCollection representing the found album.
 */
- (PHAssetCollection *)findAlbum {
    // All albums
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                              subtype:PHAssetCollectionSubtypeAny
                                                                                              options:nil];
    
    // Find album by name
    PHAssetCollection *targetCollection = nil;
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:self.albumName]) {
            targetCollection = collection;
            break;
        }
    }

    return targetCollection;
}


-(NSError *) createErrorResponse:(NSString *) description{
    
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
    };
    
    return [NSError errorWithDomain:@"Seafile"  code:-1 userInfo:userInfo];
}

@end

