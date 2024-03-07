//
//  SeafDeletedFileFolderItem.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafRecoveryItem.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafDeletedFileFolderItem
 * @brief Represents a deleted file or folder item in Seafile.
 * @note This class conforms to the SeafRecoveryItem protocol.
 */
@interface SeafDeletedFileFolderItem : NSObject<SeafRecoveryItem>

/**
 * The commit ID associated with the deleted item.
 */
@property (nonatomic, strong) NSString *commitId;

/**
 * The timestamp indicating when the item was deleted.
 */
@property (nonatomic, strong) NSString *deletedTime;

/**
 * A boolean value indicating whether the item is a directory.
 */
@property (nonatomic, assign) BOOL isDir;

/**
 * The object ID associated with the deleted item.
 */
@property (nonatomic, strong) NSString *objId;

/**
 * The name of the deleted item.
 */
@property (nonatomic, strong) NSString *objName;

/**
 * The parent directory of the deleted item.
 */
@property (nonatomic, strong) NSString *parentDir;

/**
 * The scan status of the deleted item.
 */
@property (nonatomic, strong) NSString *scanStat;

/**
 * The size of the deleted item in bytes.
 */
@property (nonatomic, assign) NSInteger size;

/**
 * The repository ID associated with the deleted item.
 */
@property (nonatomic, strong) NSString *repoId;


@property SeafRecoveryItemType recoveryItemType;

/**
 * Initializes a new instance of SeafDeletedFileFolderItem with the provided dictionary and repository ID.
 * @param dictionary The dictionary containing information about the deleted item.
 * @param repoId The repository ID associated with the deleted item.
 * @return An initialized SeafDeletedFileFolderItem object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary andRepo:(NSString *)repoId;

/**
 * Converts an array of dictionaries into an array of SeafDeletedFileFolderItem objects.
 * @param array An array of dictionaries containing information about deleted items.
 * @param repoId The repository ID associated with the deleted items.
 * @return An array of SeafDeletedFileFolderItem objects.
 */
+ (NSMutableArray<SeafDeletedFileFolderItem *> *)fromArrayDictionary:(NSArray<NSDictionary *> *)array andRepo:(NSString *)repoId;

@end

NS_ASSUME_NONNULL_END
