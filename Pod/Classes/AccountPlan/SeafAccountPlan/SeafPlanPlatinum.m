//
//  SeafPlanPlatinum.m
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanStandard.h"
#import "SeafPlanBasic.h"
#import "SeafPlanUser.h"
#import "SeafPlanEnterprise.h"
#import "SeafPlanPlatinum.h"

@implementation SeafPlanPlatinum

/**
 * @brief Initializes an instance of SeafPlanPlatinum.
 *
 * This method sets the planName to "Platinum"  and support4k to YES.
 *
 * @return An initialized instance of SeafPlanPlatinum.
 */
- (instancetype)init {
    self = [super initWithPlanName:@"Platinum"];

     if (self) {
         self.customizableBackup = YES;
         self.dontAllowedExtensions =  @[];
         self.planName = @"Platinum";
         self.maxUploadSizeFileInBytes = 10737418240; // 10 GB
         self.support4k = YES;
         self.uploadMaxPacketSizeInBytes = INFINITY;
         self.uploadDelayInSeconds = 0;
     }

     return self;

}

@end

