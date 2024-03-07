//
//  SeafEnqueueFileFactory.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import "SeafEnqueueFileFactory.h"
#import "SeafSyncAssetItem.h"
#import "SeafPhotoAsset.h"
#import "SeafStorage.h"

@implementation SeafEnqueueFileFactory

/**
 * Create a SeafUploadFile instance based on the type of synchronization item.
 *
 * @param seafSyncItem The synchronization item.
 * @return A SeafUploadFile instance.
 */
+ (SeafUploadFile *)createFrom:(id<SeafSyncItemProtocol>)seafSyncItem {
    switch (seafSyncItem.itemType) {
        case SeafSyncItemTypeFile:
            return [self createFromSyncFileType:seafSyncItem];
            break;
        case SeafSyncItemTypeAsset:
            return [self createFromSyncAssetType:seafSyncItem];
            break;
        default:
            return nil;
            break;
    }
}

/**
 * Create a SeafUploadFile instance from a file URL.
 *
 * @param fileURL The file URL.
 * @return A SeafUploadFile instance.
 */
+ (SeafUploadFile *)createFromURL:(NSURL *)fileURL {
    SeafUploadFile *uploadFile = [[SeafUploadFile alloc] initWithPath:[fileURL path]];
    uploadFile.retryable = true;
    uploadFile.removeSourceAfterUpload = FALSE;
    uploadFile.autoSync = false;
    uploadFile.overwrite = true;

    return uploadFile;
}

/**
 * Create a SeafUploadFile instance from a file-based synchronization item.
 *
 * @param seafSyncItem The synchronization item.
 * @return A SeafUploadFile instance.
 */
+ (SeafUploadFile *)createFromSyncFileType:(id<SeafSyncItemProtocol>)seafSyncItem {
    SeafUploadFile *uploadFile = [[SeafUploadFile alloc] initWithPath:[seafSyncItem.path path]];
    uploadFile.retryable = true;
    uploadFile.removeSourceAfterUpload = FALSE;
    uploadFile.autoSync = false;
    uploadFile.overwrite = true;

    return uploadFile;
}

/**
 * Create a SeafUploadFile instance from an asset-based synchronization item.
 *
 * @param seafSyncItem The synchronization item.
 * @return A SeafUploadFile instance.
 */
+ (SeafUploadFile *)createFromSyncAssetType:(id<SeafSyncItemProtocol>)seafSyncItem {
    SeafSyncAssetItem *seafSyncAssetItem = (SeafSyncAssetItem *)seafSyncItem;

    // Calculate asset path
    SeafPhotoAsset *photoAsset = [[SeafPhotoAsset alloc] initWithAsset:[seafSyncAssetItem getAsset]];
    NSString *uploadsDir = [SeafStorage uniqueDirUnder:SeafStorage.sharedObject.uploadsDir];
    NSString *path = [uploadsDir stringByAppendingPathComponent:photoAsset.name];

    // Create UploadFile
    SeafUploadFile *file = [[SeafUploadFile alloc] initWithPath:path];
    file.retryable = true;
    file.autoSync = true;
    file.overwrite = true;
    file.removeSourceAfterUpload = TRUE;
    [file setPHAsset:[seafSyncAssetItem getAsset] url:photoAsset.ALAssetURL];

    return file;
}

@end

