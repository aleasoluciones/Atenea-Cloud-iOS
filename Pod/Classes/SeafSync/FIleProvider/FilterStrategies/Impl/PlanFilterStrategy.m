//
//  PlanFilterStrategy.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 26/10/23.
//

#import "PlanFilterStrategy.h"
#import "SeafFileFilterBuilder.h"
#import "SeafFileFilterStrategy.h"


@interface PlanFilterStrategy()

@property SeafSyncSettings *settings;
@property id<SeafFileFilterStrategy> filter;

@end



@implementation PlanFilterStrategy

/**
 * @brief Initializes a new instance of the filter strategy with the specified synchronization settings.
 *
 * @param settings The synchronization settings to be used by the filter strategy.
 * @return An initialized instance of the filter strategy.
 */
-(id)initWithSettings:(SeafSyncSettings *)settings{
    self = [super init];
    if(self){
        self.settings = settings;
        self.filter = [SeafFileFilterBuilder getFilterForUpload:self.settings.connection];
    }
    
    return self;
}


/**
 * @brief Determines whether the provided item meets the specified conditions based on synchronization settings.
 *
 * @param itemToEvaluate The item to evaluate against the conditions.
 * @return YES if the item meets the conditions, NO otherwise.
 */
-(BOOL) meetsCondition:(id<SeafSyncItemProtocol>) itemToEvaluate{
    return [self.filter meetsCondition:itemToEvaluate];
}

@end
