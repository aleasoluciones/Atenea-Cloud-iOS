//
//  SeafPlanStandard.m
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanStandard.h"
#import "SeafPlanBasic.h"
#import "SeafPlanUser.h"

@implementation SeafPlanStandard

/**
 * @brief Initializes an instance of SeafPlanStandard.
 *
 * This method sets the planName to "Standard" and customizableBackup to YES.
 *
 * @return An initialized instance of SeafPlanStandard.
 */
- (instancetype)init {
    self = [super initWithPlanName:@"Standard"];
  
     if (self) {
         self.customizableBackup = YES;
     }
     return self;
        
}

@end
