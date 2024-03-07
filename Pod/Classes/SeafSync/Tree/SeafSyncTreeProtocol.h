/**
 * @file SeafSyncTreeProtocol.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncTreeProtocol protocol.
 *
 * This file contains the declaration of the SeafSyncTreeProtocol protocol, which defines the interface for synchronized tree structures.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncEnums.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SeafSyncTreeProtocol

/**
 * Returns the tree node Id.
 *
 * @return The tree node Id as a string.
 */
-(NSString *)getId;

/**
 * Sets the tree node Id.
 *
 * @param identifier The tree node Id to set.
 */
-(void)setId:(NSString *) identifier;

/**
 * Returns the associated sync ID.
 *
 * @return The associated sync ID as a string.
 */
-(NSString *)getSyncSettingId;

/**
 * Sets the associated sync ID.
 *
 * @param syncSettingId The associated sync ID to set.
 */
-(void)setSyncSettingId:(NSString *) syncSettingId;

/**
 * Returns the tree node type.
 *
 * @return The tree node type as a SyncTreeType enum.
 */
-(SyncTreeType)getType;

/**
 * Sets the tree node type.
 *
 * @param type The tree node type to set.
 */
-(void)setType:(SyncTreeType) type;

/**
 * Returns the nested data URL.
 *
 * @return The nested data URL as an NSURL.
 */
-(NSURL *)getURL;

/**
 * Sets the nested data URL.
 *
 * @param url The nested data URL to set.
 */
-(void)setURL:(NSURL *) url;

/**
 * Adds children to this item.
 *
 * @param children The children to add.
 */
-(void) addChildren:(id<SeafSyncTreeProtocol>) children;

/**
 * Gets children.
 *
 * @return An array of id<SeafSyncTreeProtocol> objects representing the children.
 */
-(NSMutableArray<id<SeafSyncTreeProtocol>> *) getChildrens;

/**
 * Clears children.
 */
-(void) clearChildrens;

/**
 * Gets all children filtered by type.
 *
 * @param treeType The type of children to filter.
 * @return An array of children of the specified type.
 */
-(NSArray<id<SeafSyncTreeProtocol>> *) getAllChildrensOfType:(SyncTreeType) treeType;

/**
 * Gets children filtered by type.
 *
 * @param treeType The type of children to filter.
 * @return An array of children of the specified type.
 */
-(NSArray<id<SeafSyncTreeProtocol>> *) getChildrensOfType:(SyncTreeType) treeType;

/**
 * Filters tree items by predicate.
 *
 * @param parent The parent tree.
 * @param predicate The predicate to filter by.
 * @return An array of id<SeafSyncTreeProtocol> objects filtered by the specified predicate.
 */
-(NSArray<id<SeafSyncTreeProtocol>> *) getChildrensFrom:(id<SeafSyncTreeProtocol>) parent withPredicate:(NSPredicate *) predicate;

/**
 * Returns the complete tree hash.
 *
 * @return The complete tree hash as a string.
 */
-(NSString *)getFullHash;

/**
 * Sets the complete tree hash.
 *
 * @param hash The complete tree hash to set.
 */
-(void)setFullHash:(NSString *) hash;

/**
 * Returns the relative hash.
 *
 * @return The relative hash as a string.
 */
-(NSString *)getRelativeHash;

/**
 * Sets the relative hash.
 *
 * @param hash The relative hash to set.
 */
-(void)setRelativeHash:(NSString *) hash;


/**
 * Sets the size
 *
 * @param size the size in bytes
 */
-(void)setSizeInBytes:(long long) size;


/**
* Returns node size
*
* @return The tree node size
*/
-(long long)sizeInBytes;

@end

NS_ASSUME_NONNULL_END

