//
//  SeafSyncFilteredProvider.m
//  Seafile
//
//  Created by apps Javier Godoy (javigodoy@meytel.net) on 10/10/23.
//

#import "SeafSyncFilteredProvider.h"

/**
 * @brief Private interface for SeafSyncFilteredProvider.
 */
@interface SeafSyncFilteredProvider()

/**
 * @brief The provider to filter.
 */
@property (nonatomic, retain) id<SeafSyncProviderProtocol> provider;

/**
 * @brief Array of filter strategies to apply to the files.
 */
@property NSArray<id<SeafSyncFileProviderFilterStrategy>> *filters;

@end

/**
 * @brief This provider acts as a wrapper for another provider received in the constructor.
 * When invoking the 'getFiles' method, it requests files from the provider injected in the constructor
 * and applies a series of filters to the files returned by it using strategies
 * (classes that implement the 'SeafSyncFileProviderFilterStrategy' protocol).
 *
 * So, the flow would be:
 * getFiles (this class calls to) => getFiles (in injected provider) => with those files =>
 * apply filters => return filtered files
 */
@implementation SeafSyncFilteredProvider

/**
 * @brief Initializes a new instance of the filtered synchronization provider
 * with the specified base provider and filters.
 *
 * @param provider The base provider to retrieve files from.
 * @param filters An array of filter strategies to apply to the files retrieved from the base provider.
 * @return An initialized instance of the filtered synchronization provider.
 */
-(id)initWithProvider:(id<SeafSyncProviderProtocol>)provider andFilters:(NSArray<id<SeafSyncFileProviderFilterStrategy>> *)filters{
    self  = [super init];
    if (self) {
        self.provider = provider;
        self.filters = filters;
    }
    
    return self;
}

/**
 * @brief Retrieves the list of filtered files from the base provider.
 *
 * @param onError An optional error parameter to capture any errors that occur during the operation.
 * @return An array of items conforming to the SeafSyncItemProtocol, filtered based on the specified filters.
 */
- (nonnull NSMutableArray<id<SeafSyncItemProtocol>> *)getFiles:(NSError *__autoreleasing  _Nullable * _Nullable) onError {
    
    NSError *error = nil;
    
    NSMutableArray<id<SeafSyncItemProtocol>> *files = [self.provider getFiles:&error];
    
    if(error){
        *onError = error;
        return [[NSMutableArray alloc] initWithCapacity:0];
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id<SeafSyncItemProtocol> syncItem, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        for (id<SeafSyncFileProviderFilterStrategy> filter in self.filters) {
            if(! [filter meetsCondition:syncItem ]){
                return FALSE;
            }
        }
        
        return TRUE;
    }];
    
    files = [[NSMutableArray alloc] initWithArray:[files filteredArrayUsingPredicate:predicate]] ;
    
    return files;
}




@end
