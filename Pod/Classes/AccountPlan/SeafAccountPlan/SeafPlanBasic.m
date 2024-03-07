//
//  SeafPlanBasic.m
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanBasic.h"
#import "SeafPlanUser.h"

@implementation SeafPlanBasic

/**
 * @brief Initializes an instance of SeafPlanBasic.
 *
 * This method sets the planName to "Basic", customizableBackup to NO, and
 * allowedExtensions to a predefined list.
 *
 * @return An initialized instance of SeafPlanBasic.
 */
- (instancetype)init {
    self = [super initWithPlanName:@"Basic"];
     return self;
}

@end
