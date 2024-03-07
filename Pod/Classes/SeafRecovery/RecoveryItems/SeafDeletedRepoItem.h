//
//  SeafDeletedRepoItem.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafRecoveryItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafDeletedRepoItem
 * @brief Represents a deleted repository item in Seafile.
 * @note This class conforms to the SeafRecoveryItem protocol.
 */
@interface SeafDeletedRepoItem : NSObject<SeafRecoveryItem>

/**
 * The timestamp indicating when the repository was deleted.
 */
@property (nonatomic, strong) NSString *delTime;

/**
 * An integer value indicating whether the repository is encrypted.
 */
@property (nonatomic, assign) NSInteger encrypted;

/**
 * The head commit ID associated with the repository.
 */
@property (nonatomic, strong) NSString *headCommitId;

/**
 * The organization ID associated with the repository.
 */
@property (nonatomic, strong) NSString *orgId;

/**
 * The contact email of the owner of the repository.
 */
@property (nonatomic, strong) NSString *ownerContactEmail;

/**
 * The email of the owner of the repository.
 */
@property (nonatomic, strong) NSString *ownerEmail;

/**
 * The name of the owner of the repository.
 */
@property (nonatomic, strong) NSString *ownerName;

/**
 * The repository ID associated with the repository.
 */
@property (nonatomic, strong) NSString *repoId;

/**
 * The name of the repository.
 */
@property (nonatomic, strong) NSString *repoName;

/**
 * The size of the repository in bytes.
 */
@property (nonatomic, assign) NSInteger size;


@property SeafRecoveryItemType recoveryItemType;

/**
 * Initializes a new instance of SeafDeletedRepoItem with the provided dictionary.
 * @param dictionary The dictionary containing information about the deleted repository.
 * @return An initialized SeafDeletedRepoItem object.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Converts an array of dictionaries into an array of SeafDeletedRepoItem objects.
 * @param array An array of dictionaries containing information about deleted repositories.
 * @return An array of SeafDeletedRepoItem objects.
 */
+ (NSMutableArray<SeafDeletedRepoItem *> *)fromArrayDictionary:(NSArray<NSDictionary *> *)array;

@end

NS_ASSUME_NONNULL_END
