/**
 * @file SeafSyncTree.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncTree class.
 *
 * This file contains the implementation of the SeafSyncTree class, which represents a synchronized tree structure.
 */

#import "SeafSyncTree.h"
#import "SeafSyncUtils.h"


@interface SeafSyncTree()

@property (nonatomic, strong, nullable) NSString *identifier;
@property (nonatomic) SyncTreeType type;
@property (nonatomic, strong, nullable) NSURL *url;
@property (nonatomic, strong, nullable) NSString *syncSettingId;
@property (nonatomic, strong, nullable) NSString *fullHash;
@property (nonatomic, strong, nullable) NSString *relativeHash;
@property (nonatomic) long long _sizeInBytes;
@property (nonatomic, strong) NSMutableArray<SeafSyncTree *> *childrens;

@end

@implementation SeafSyncTree

/**
 * Initializes an instance of SeafSyncTree.
 *
 * @return An instance of SeafSyncTree.
 */
-(instancetype)init{
    self = [super init];
    if(self){
        self.type = TreeRoot;
        self.childrens = [[NSMutableArray<SeafSyncTree *> alloc] initWithCapacity:0];
    }
    return self;
}

/**
 * Returns the tree node Id.
 *
 * @return The tree node Id as a string.
 */
-(NSString *)getId{
    return _identifier;
}

/**
 * Sets the tree node Id.
 *
 * @param identifier The tree node Id to set.
 */
-(void)setId:(NSString *) identifier{
    _identifier = identifier;
}

/**
 * Returns the associated sync ID.
 *
 * @return The associated sync ID as a string.
 */
-(NSString *)getSyncSettingId{
    return _syncSettingId;
}

/**
 * Sets the associated sync ID.
 *
 * @param syncSettingId The associated sync ID to set.
 */
-(void)setSyncSettingId:(NSString *) syncSettingId{
    _syncSettingId = syncSettingId;
}

/**
 * Sets the tree node type.
 *
 * @param type The tree node type to set.
 */
-(void)setType:(SyncTreeType) type{
   _type = type;
}

/**
 * Returns the tree node type.
 *
 * @return The tree node type as a SyncTreeType enum.
 */
-(SyncTreeType)getType{
    return _type;
}

/**
 * Returns the nested data URL.
 *
 * @return The nested data URL as an NSURL.
 */
-(NSURL *)getURL{
    return _url;
}

/**
 * Sets the nested data URL.
 *
 * @param url The nested data URL to set.
 */
-(void)setURL:(NSURL *) url{
    _url = url;
}

/**
 * Returns the complete tree hash.
 *
 * @return The complete tree hash as a string.
 */
-(NSString *)getFullHash{
    self.identifier = (self.identifier != nil) ? self.identifier : @"";
    
    NSMutableString *hash = [[NSMutableString alloc] initWithString:self.identifier];
    
    for (SeafSyncTree *child in self.childrens) {
        [hash appendFormat:@".%@",[child getFullHash]];
    }
    
    return [SeafSyncUtils calculateHash:hash];
}

/**
 * Sets the complete tree hash.
 *
 * @param hash The complete tree hash to set.
 */
-(void)setFullHash:(NSString *) hash{
}

/**
 * Returns the relative hash.
 *
 * @return The relative hash as a string.
 */
-(NSString *)getRelativeHash{
    self.identifier = (self.identifier != nil) ? self.identifier : @"";
    
    NSMutableString *hash = [[NSMutableString alloc] initWithString:self.identifier];
    
    for (SeafSyncTree *child in self.childrens) {
        [hash appendFormat:@".%@",child.identifier];
    }
    
    return [SeafSyncUtils calculateHash:hash];
}

/**
 * Sets the relative hash.
 *
 * @param hash The relative hash to set.
 */
-(void)setRelativeHash:(NSString *) hash{
}

/**
 * Adds children to this item.
 *
 * @param children The children to add.
 */
-(void) addChildren:(SeafSyncTree *) children{
    [self.childrens addObject:children];
}

/**
 * Clears children.
 */
-(void) clearChildrens{
    [self.childrens removeAllObjects];
}

/**
 * Gets children.
 *
 * @return An array of SeafSyncTree objects representing the children.
 */
-(NSMutableArray<SeafSyncTree *> *) getChildrens{
    return self.childrens;
}

/**
 * Gets ALL children filtered by type.
 *
 * @param treeType The type of children to filter.
 * @return An array of children of the specified type.
 */
-(NSArray<id<SeafSyncTreeProtocol>> *) getAllChildrensOfType:(SyncTreeType) treeType{
    NSPredicate *typePredicate = [NSPredicate predicateWithBlock:^BOOL(id tree, NSDictionary *bindings) {
        return [(SeafSyncTree *) tree getType] == treeType;
    }];
    return [self getChildrensFrom:self withPredicate:typePredicate];
}

/**
 * Gets children filtered by type.
 *
 * @param treeType The type of children to filter.
 * @return An array of children of the specified type.
 */
-(NSArray<id<SeafSyncTreeProtocol>> *) getChildrensOfType:(SyncTreeType) treeType{
    NSPredicate *typePredicate = [NSPredicate predicateWithBlock:^BOOL(id tree, NSDictionary *bindings) {
        return [(SeafSyncTree *) tree getType] == treeType;
    }];
    NSMutableArray *childrens = [[self getChildrens] mutableCopy];
    [childrens filterUsingPredicate:typePredicate];
    return childrens;
}

/**
 * Filters all items by predicate.
 *
 * @param parent The parent tree.
 * @param predicate The predicate to filter by.
 * @return An array of SeafSyncTree objects filtered by the specified predicate.
 */
-(NSArray<SeafSyncTree *> *) getChildrensFrom:(SeafSyncTree *) parent withPredicate:(NSPredicate *) predicate{
    NSArray *filteredItems = [parent.childrens filteredArrayUsingPredicate:predicate];
    
    for (SeafSyncTree *children in parent.childrens) {
        filteredItems = [filteredItems arrayByAddingObjectsFromArray:[self getChildrensFrom:children withPredicate:predicate]];
    }
    return filteredItems;
}


/**
 * Sets the size
 *
 * @param size the size in bytes
 */
-(void)setSizeInBytes:(long long) size{
    self._sizeInBytes = size;
}


/**
* Returns node size
*
* @return The tree node size
*/
-(long long)sizeInBytes{
    return self._sizeInBytes;
}



/**
 * NSCopying method to create a copy of the object.
 *
 * @param zone The memory zone to create the copy in.
 * @return A copy of the SeafSyncTree object.
 */
- (id)copyWithZone:(NSZone *)zone {
    SeafSyncTree *tree = [[SeafSyncTree allocWithZone:zone] init];
    tree.url = [self.url copy];
    tree.identifier = [[self.identifier copy] stringValue];
    tree.syncSettingId = [[self.syncSettingId copy] stringValue];
    tree.relativeHash = [[self.relativeHash copy] stringValue];
    tree.fullHash = [[self.fullHash copy] stringValue];
    tree.type = self.type;
    tree.childrens = [self.childrens mutableCopy];
    return tree;
}

@end

