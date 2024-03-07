//
//  SeafUIBridge.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The `SeafUIBridge` class serves as a bridge for UI-related operations,
 * allowing easy integration with the Seafile app.
 */
@interface SeafUIBridge : NSObject

/**
 * Initializes the `SeafUIBridge` with the specified view controller.
 *
 * @param window The UIWindowto initialize the bridge with.
 */
+ (void)initializeWith:(UIWindow *)window;

/**
 * Returns the shared instance of the `SeafUIBridge`.
 *
 * @return The shared instance of the `SeafUIBridge`.
 */
+ (instancetype)sharedInstance;

/**
 * Returns the shared instance of the `UIViewController`.
 *
 * @return The shared instance of the `UIViewController`.
 */
- (UIViewController *)viewController;

/**
 * Presents a view controller modally.
 *
 * @param viewControllerToPresent The view controller to be presented.
 * @param flag A flag indicating whether the presentation should be animated.
 * @param completion A block to be executed after the presentation animation completes.
 */
- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^ _Nullable)(void))completion;



-(void) alert:(NSString *) title message:(NSString *) message;

@end

NS_ASSUME_NONNULL_END
