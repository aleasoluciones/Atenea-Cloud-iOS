//
//  SeafFileUploadFilter.m
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//

#import <Foundation/Foundation.h>

#import "SeafFileFilterStrategy.h"
#import "SeafUIBridge.h"
#import "SeafAlertChangePlan.h"
#import "SeafCompositeFilter.h"
#import "SeafAlertChangePlan.h"

@interface SeafCompositeFilter()

@property NSArray<id<SeafFileFilterStrategy>> *filters;

@end

@implementation SeafCompositeFilter

- (instancetype)initWithFilters:(NSArray<id<SeafFileFilterStrategy>> *)filters {
    self = [super init];
    if (self) {
        self.filters = filters;
    }
    return self;
}

- (BOOL)meetsCondition:(nonnull id<SeafFileProtocol>)itemToEvaluate  {
    for (id<SeafFileFilterStrategy> filter in self.filters) {
        if (![filter meetsCondition:itemToEvaluate]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)meetsCondition:(nonnull id<SeafFileProtocol>)itemToEvaluate firstFailedFilter:(id<SeafFileFilterStrategy> _Nullable *_Nullable)firstFailedFilter {
    for (id<SeafFileFilterStrategy> filter in self.filters) {
        if (![filter meetsCondition:itemToEvaluate]) {
            *firstFailedFilter = filter;
            return NO;
        }
    }
    return YES;
}

@end


