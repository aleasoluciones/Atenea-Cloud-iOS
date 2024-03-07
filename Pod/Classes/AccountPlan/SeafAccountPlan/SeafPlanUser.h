//
//  SeafPlanUser.h
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>

/**
 * @class SeafPlanUser
 * @brief Base class representing a user's plan.
 */
@interface SeafPlanUser : NSObject

/**
 * @brief The name of the plan.
 */
@property (nonatomic, strong) NSString *planName;

/**
 * @brief An array of allowed file extensions for the plan.
 */
@property (nonatomic, strong) NSArray<NSString *> *dontAllowedExtensions;


/**
 * @brief Property that indicates whether the plan supports 4K content.
 */
@property (nonatomic, assign) BOOL support4k;

/**
 * @brief Property that specifies the upload speed for the enterprise plan.
 */
@property (nonatomic, assign) double uploadMaxPacketSizeInBytes;


/**
 * @brief Property that specifies the upload speed for the enterprise plan.
 */
@property (nonatomic, assign) double uploadDelayInSeconds;

/**
 * @brief Property that indicates whether custom backup is allowed.
 */
@property (nonatomic, assign) BOOL customizableBackup;

/**
 * .
 */
@property (nonatomic, assign) long long maxUploadSizeFileInBytes;


/**
 * @brief Initializes an instance of SeafPlanUser with the given planName.
 *
 * @param planName The name of the plan.
 * @return An initialized instance of SeafPlanUser.
 */
- (instancetype)initWithPlanName:(NSString *)planName;

@end
