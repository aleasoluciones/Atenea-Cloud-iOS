//
//  SeafSyncAssetItem.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import "SeafSyncAssetItem.h"
#import "SeafSyncUtils.h"
#import <objc/runtime.h>

@interface SeafSyncAssetItem()

/**
 * @brief The Photo Library asset associated with this item.
 */
@property (nonatomic, strong) PHAsset *asset;

@end

@implementation SeafSyncAssetItem

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
 * @brief Initializes a new instance of the asset item with the specified Photo Library asset.
 *
 * @param asset The Photo Library asset to be represented by the item.
 * @return An initialized instance of the asset item.
 */
-(id)initWithPHAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        [self fillProperties];
    }
    
    return self;
}

/**
 * @brief Retrieves the Photo Library asset represented by the item.
 *
 * @return The Photo Library asset represented by the item.
 */
-(PHAsset *)getAsset {
    return self.asset;
}

/**
 * @brief Fills various properties of the asset item based on the associated Photo Library asset.
 */
- (void)fillProperties {
    self.path = [self assetURL:self.asset];

    self.creationDate = self.asset.creationDate;
    self.addedToDirectoryDate = self.asset.creationDate;
    self.identifier = self.asset.localIdentifier;
    self.isDirectory = false;
    self.itemType = SeafSyncItemTypeAsset;
    self.fileHash = self.asset.localIdentifier;
    [self setFileType];
    [self setAssetNameAndExtension];
    [self setAssetSize];
}

/**
 * @brief Sets the file type based on the media type of the associated asset.
 */
- (void)setFileType {
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        self.fileType = SeafSyncItemFileTypeVideo;
        return;
    }

    if (self.asset.mediaType == PHAssetMediaTypeImage) {
        self.fileType = SeafSyncItemFileTypeImage;
        return;
    }

    if (self.asset.mediaType == PHAssetMediaTypeAudio) {
        self.fileType = SeafSyncItemFileTypeAudio;
        return;
    }

    self.fileType = SeafSyncItemFileTypeOther;
}



/**
 * @brief Sets the file extension based on the original filename of the asset.
 */
- (void)setAssetNameAndExtension {
    PHAssetResource *assetResource = [[PHAssetResource assetResourcesForAsset:self.asset] firstObject];
    self.extension = [assetResource.originalFilename.pathExtension lowercaseString];
    self.fileName = assetResource.originalFilename;

}

/**
 * @brief Sets the size in bytes based on the media type of the associated asset.
 */
- (void)setAssetSize {
    switch (self.asset.mediaType) {
        case PHAssetMediaTypeVideo:
            [self setVideoAssetSize];
            break;
            
        default:
            [self setImageAssetSize];
            break;
    }
}

/**
 * @brief Sets the size in bytes for an image asset.
 */
- (void)setImageAssetSize {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES; // Set to NO for asynchronous requests

    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset
                                                      options:options
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (imageData) {
            NSUInteger imageSize = [imageData length];
            self.sizeInBytes = (long long)imageSize;
        }
    }];
}

/**
 * @brief Sets the size in bytes for a video asset.
 */
- (void)setVideoAssetSize {
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:self.asset];
    
    __block NSUInteger totalSize = 0;
    
    for (PHAssetResource *resource in resources) {
        NSNumber *sizeNumber = [resource valueForKey:@"fileSize"];
        totalSize += [sizeNumber unsignedIntegerValue];
    }
 
    self.sizeInBytes = (long long)totalSize;
}

/**
 * @brief Retrieves the asset URL from the associated asset using reflection.
 *
 * @param asset The Photo Library asset.
 * @return The URL of the asset.
 */
- (NSURL *)assetURL:(PHAsset *)asset {
    NSURL *URL;
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([asset class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        if ([[NSString stringWithUTF8String:propertyName] isEqualToString:@"ALAssetURL"]) {
            if ([[asset valueForKey:@"ALAssetURL"] isKindOfClass:[NSURL class]]) {
                URL = [asset valueForKey:@"ALAssetURL"];
            }
            break;
        }
    }
    free(propertyList);
    return URL;
}

@end

