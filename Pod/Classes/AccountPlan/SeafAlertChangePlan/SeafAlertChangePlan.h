//
//  SeafAlertChangePlan.h
//  Pods
//
//  Created by apps meytel on 11/10/23.
#define SeafAlertChangePlan_h

#import <UIKit/UIKit.h>
#import "SeafFileFilterStrategy.h"

/**
 * @class SeafAlertChangePlan
 * This class represents a view controller for displaying alert messages related to changing plans.
 */
@interface SeafAlertChangePlan : NSObject

+ (void) showAlertWithFilterStrategy:(id<SeafFileFilterStrategy> _Nullable)filterStrategy;

+ (void) showAlert: (NSString *_Nonnull)message;

+ (void) showAlert: (NSString *_Nonnull)message into:(UIViewController *_Nonnull) controller;


@end
