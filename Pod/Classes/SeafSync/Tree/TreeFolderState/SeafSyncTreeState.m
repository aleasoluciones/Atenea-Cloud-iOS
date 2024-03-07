//
//  SeafSyncFolderTreeState.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 22/9/23.
//

#import "SeafSyncTreeState.h"
#import "SeafSyncEnums.h"
#import "SeafSyncTreeProtocol.h"


@interface SeafSyncTreeState()




@property NSMutableArray<id<SeafSyncTreeProtocol>> *childrens;


@property (nonatomic) SyncTreeType type;
@property (nonatomic) NSString  *syncSettingId;
@property (nonatomic) NSString  *identifier;
@property (nonatomic) NSString  *relativeHash;
@property (nonatomic) NSString  *fullHash;
@property (nonatomic) NSURL  *url;
@property (nonatomic) long long _sizeInBytes;

@end



@implementation SeafSyncTreeState


-(id) init{
    
    self = [super init];
    
    if (self) {
        self.childrens = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}


- (void)addChildren:(nonnull id<SeafSyncTreeProtocol>)children {
    [self.childrens addObject:children];
}


- (nonnull NSArray<id<SeafSyncTreeProtocol>> *)getAllChildrensOfType:(SyncTreeType)treeType {
    return self.childrens;
}


- (nonnull NSMutableArray<id<SeafSyncTreeProtocol>> *)getChildrens {
    return self.childrens;
}


- (nonnull NSArray<id<SeafSyncTreeProtocol>> *)getChildrensFrom:(nonnull id<SeafSyncTreeProtocol>)parent withPredicate:(nonnull NSPredicate *)predicate {
    return self.childrens;
}


- (nonnull NSString *)getId {
    return self.identifier;
}


- (SyncTreeType)getType {
    return self.type;
}


- (nonnull NSURL *)getURL {
    return self.url;
}


- (nonnull NSString *)getRelativeHash {
    return self.relativeHash;
}


- (void)setId:(nonnull NSString *)identifier {
    _identifier = identifier;
}


- (void)setType:(SyncTreeType)type {
   _type  = type;
}


- (void)setURL:(nonnull NSURL *)url {
    _url = url;
}

- (nonnull NSString *)getSyncSettingId {
    return self.syncSettingId;
}

- (void)setSyncSettingId:(NSString *)syncSettingId {
    _syncSettingId = syncSettingId;
}



///The complete three hash
///
///Returns the full hash for all subdirectories & files
-(NSString *)getFullHash{
    return self.fullHash;
}

///Sets the complete tree hash
-(void)setFullHash:(NSString *) hash{
    _fullHash = hash;
}



///Sets the relative hash
-(void)setRelativeHash:(NSString *) hash{
    _relativeHash = hash;
}

- (void)clearChildrens {
    [self.childrens removeAllObjects];
}


- (nonnull NSArray<id<SeafSyncTreeProtocol>> *)getChildrensOfType:(SyncTreeType)treeType {
    NSPredicate *typePredicate = [NSPredicate predicateWithBlock:^BOOL(id tree, NSDictionary *bindings) {
        return [tree getType] == treeType;
    }];
    NSMutableArray *childrens = [[self getChildrens] mutableCopy];
    [childrens filterUsingPredicate:typePredicate];
    return childrens;
}


- (void)setSizeInBytes:(long long)size {
    self._sizeInBytes = size;
}


- (long long)sizeInBytes {
    return self._sizeInBytes;
}




@end
