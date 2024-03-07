//
//  SeafUIBridge.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import "SeafUIBridge.h"

@interface SeafUIBridge()

@property (nonatomic) UIWindow *window;

@end

@implementation SeafUIBridge

/**
 * Initializes the `SeafUIBridge` with the specified view controller.
 *
 * @param window The UIWindow to initialize the bridge with.
 */
+ (void)initializeWith:(UIWindow *)window {
    SeafUIBridge *instance = [self sharedInstance];
    [instance setUIWindow:window];
}

/**
 * Returns the shared instance of the `SeafUIBridge`.
 *
 * @return The shared instance of the `SeafUIBridge`.
 */
+ (instancetype)sharedInstance {
    static SeafUIBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

/**
 * Sets the root view controller for the `SeafUIBridge`.
 *
 * @param window The UIWindow to set as the root.
 */
- (void)setUIWindow:(UIWindow *)window {
    self.window = window;
}

/**
 Returns the shared window rootViewController
 *
 */
- (UIViewController *)viewController{
    return self.window.rootViewController;
}

/**
 * Presents a view controller modally.
 *
 * @param viewControllerToPresent The view controller to be presented.
 * @param flag A flag indicating whether the presentation should be animated.
 * @param completion A block to be executed after the presentation animation completes.
 */
- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^ _Nullable)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window.rootViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    });
}



-(void) alert:(NSString *) title message:(NSString *) message{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title  message:message  preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end

