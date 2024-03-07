//
//  SeafSyncItemProtocol.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafFileProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Enumeration representing the type of synchronization item.
 */
typedef NS_ENUM(NSInteger, SeafSyncItemType) {
    SeafSyncItemTypeFile,    ///< Synchronization item is a file.
    SeafSyncItemTypeFolder,  ///< Synchronization item is a folder.
    SeafSyncItemTypeAsset    ///< Synchronization item is an asset.
};

/**
 Enumeration representing the file type of synchronization item.
 */
typedef NS_ENUM(NSInteger, SeafSyncItemFileType) {
    SeafSyncItemFileTypeImage,  ///< Synchronization item is an image file.
    SeafSyncItemFileTypeVideo,  ///< Synchronization item is a video file.
    SeafSyncItemFileTypeAudio,  ///< Synchronization item is an audio file.
    SeafSyncItemFileTypeOther   ///< Synchronization item is of an unknown or other type.
};

/**
 * @protocol SeafSyncItemProtocol
 * @brief A protocol representing synchronization items.
 */
@protocol SeafSyncItemProtocol <SeafFileProtocol>

/**
 The unique identifier for the synchronization item.
 */
@property (nonatomic, strong) id identifier;

/**
 The date of creation for these sync settings.
 */
@property (nonatomic, strong) NSDate *creationDate;

/**
 The date since this file is added to its parent directory.
 */
@property (nonatomic, strong) NSDate *addedToDirectoryDate;

/**
 A boolean indicating whether the synchronization item is a directory.
 */
@property (nonatomic) BOOL isDirectory;

/**
 The size of the synchronization item in bytes.
 */
@property (nonatomic) long long sizeInBytes;

/**
 The type of synchronization item.
 */
@property (nonatomic) SeafSyncItemType itemType;

/**
 The local file path of the synchronization item.
 */
@property (nonatomic, strong) NSURL *path;

/**
 The hash of the synchronization item file.
 */
@property (nonatomic, strong) NSString *fileHash;

/**
 The file type of the synchronization item.
 */
@property (nonatomic) SeafSyncItemFileType fileType;

/**
 The extension of the synchronization item file.
 */
@property (nonatomic, strong) NSString *extension;

/**
 The name of the synchronization item file.
 */
@property (nonatomic, strong) NSString *fileName;

@end

NS_ASSUME_NONNULL_END

