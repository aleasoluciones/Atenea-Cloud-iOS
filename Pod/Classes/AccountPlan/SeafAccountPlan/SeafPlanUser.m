//
//  SeafPlanUser.m
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"

@implementation SeafPlanUser

/**
 * @brief Initializes an instance of SeafPlanUser with the given planName.
 *
 * This method sets the planName property with the provided planName.
 *
 * @param planName The name of the plan.
 * @return An initialized instance of SeafPlanUser.
 */
- (instancetype)initWithPlanName:(NSString *)planName{
    self = [super init];
    if (self) {
        self.planName = planName;
        self.maxUploadSizeFileInBytes = 1073741824; // 1 GB
        self.support4k = NO;
        self.dontAllowedExtensions = @[@"tiff", @"raw", @"psd", @"eps", @"ai", @"svg", @"flv", @"wmv"];
        self.customizableBackup = NO;
        self.uploadMaxPacketSizeInBytes = 104857.6; // => 1Mb divided by 10 iterations (0.1 delay in seconds) (In Kb)
        self.uploadDelayInSeconds = 0.1;
        
    }

    return self;
}

@end
