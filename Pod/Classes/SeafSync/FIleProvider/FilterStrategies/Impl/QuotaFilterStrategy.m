//
//  QuotaFilterStrategy.m
//  Seafile
//
//  Created by apps Javier Godoy (javigodoy@meytel.net) on 10/10/23.
//

#import "QuotaFilterStrategy.h"
#import "SeafQuotaSupervisor.h"
#import "SeafSyncErrorLogger.h"


@interface QuotaFilterStrategy ()

@property SeafSyncSettings *settings;
@property SeafQuotaSupervisor *quotaSupervisor;

@end

@implementation QuotaFilterStrategy

/**
 * @brief Initializes a new instance of the filter strategy with the specified SeafSyncSettings.
 *
 * @param settings The SeafSyncSettings to be used by the filter strategy.
 * @return An initialized instance of the filter strategy.
 */
-(id)initWithSettings:(SeafSyncSettings *)settings{
    self = [super init];
    if(self){
        self.settings = settings;
        self.quotaSupervisor = [SeafQuotaSupervisor sharedInstanceFor:settings.connection];
    }
    
    return self;
}

/**
 * @brief Determines whether the provided item meets the specified conditions based on quota.
 *
 * @param itemToEvaluate The item to evaluate against the conditions.
 * @return YES if there is enough space to upload the item, NO otherwise.
 */
-(BOOL) meetsCondition:(id<SeafSyncItemProtocol>) itemToEvaluate{
    
    BOOL meetsCondition = [self.quotaSupervisor isEnoughSpaceToUpload:[itemToEvaluate sizeInBytes]];
    
    if(FALSE == meetsCondition){
        [[SeafSyncErrorLogger sharedInstance] log:[[SeafSyncQuotaExceededError alloc] init] inSetting:self.settings];
    }
    
    return meetsCondition;
}

@end
