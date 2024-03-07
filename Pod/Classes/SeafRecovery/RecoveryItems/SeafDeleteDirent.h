//
//  SeafDeleteDirent.h
//  Seafile
//
//   Created by Javier Godoy (javigodoy@meytel.net) on 15/12/23.
//

#import <Foundation/Foundation.h>
#import "SeafRecoveryItem.h"


NS_ASSUME_NONNULL_BEGIN

@interface SeafDeleteDirent : NSObject<SeafRecoveryItem>


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
@property (nonatomic, strong) NSString *name;

/**
 * The parent directory of the deleted item.
 */
@property (nonatomic, strong) NSString *parentDir;


/**
 * The size of the deleted item in bytes.
 */
@property (nonatomic, assign) NSInteger size;


@property SeafRecoveryItemType recoveryItemType;


/**
 * Initializes a new instance of SeafDeletedFileFolderItem with the provided dictionary and repository ID.
 * @param dictionary The dictionary containing information about the deleted item.
 * @return An initialized SeafDeletedFileFolderItem object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary andParentDeletion:(id<SeafRecoveryItem>) parentDeletion;

/**
 * Converts an array of dictionaries into an array of SeafDeletedFileFolderItem objects.
 * @param array An array of dictionaries containing information about deleted items.
 * @return An array of SeafDeletedFileFolderItem objects.
 */
+ (NSMutableArray<SeafDeleteDirent *> *)fromArrayDictionary:(NSArray<NSDictionary *> *)array andParentDeletion:(id<SeafRecoveryItem>) parentDeletion;


@end

NS_ASSUME_NONNULL_END
