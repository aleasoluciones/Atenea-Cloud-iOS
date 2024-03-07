//
//  SeafFileUploadFilter.h
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//


#import <Foundation/Foundation.h>
#import "SeafFileFilterStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafCompositeFilter : NSObject<SeafFileFilterStrategy>

- (instancetype)initWithFilters:(nullable NSArray<id<SeafFileFilterStrategy>> *)filters;

- (BOOL)meetsCondition:(nonnull id<SeafFileProtocol>)itemToEvaluate firstFailedFilter:(id<SeafFileFilterStrategy> _Nullable *_Nullable)firstFailedFilter;

@end

NS_ASSUME_NONNULL_END
