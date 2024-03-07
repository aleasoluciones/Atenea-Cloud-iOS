//
//  SeafPlanEnterprise.m
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanStandard.h"
#import "SeafPlanBasic.h"
#import "SeafPlanUser.h"
#import "SeafPlanEnterprise.h"

@implementation SeafPlanEnterprise

/**
 * @brief Initializes an instance of SeafPlanEnterprise.
 *
 * This method sets the planName to "Enterprise" and defines a list of allowed extensions for the enterprise plan.
 *
 * @return An initialized instance of SeafPlanEnterprise.
 */
- (instancetype)init {
    self = [super initWithPlanName:@"Enterprise"];

     if (self) {
         self.customizableBackup = YES;
         self.dontAllowedExtensions =  @[];
         //self.uploadMaxPacketSizeInBytes = 2097152; // 2MB
         //self.uploadDelayInSeconds = 0.2;
         self.uploadMaxPacketSizeInBytes = 131072; // => 2.5Mb divided by 20 iterations (0.05 delay in seconds) (In Kb)
         self.uploadDelayInSeconds = 0.05;
         
     }
   
     return self;
        
}

@end

