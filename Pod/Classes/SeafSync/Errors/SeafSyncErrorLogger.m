//
//  SeafSyncErrorLogger.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net)  on 11/10/23.
//

#import "SeafSyncErrorLogger.h"
#import "SeafUIBridge.h"
#import "SeafSyncSettingsService.h"
#import <UIKit/UIKit.h>

@interface SeafSyncErrorLogger()

@end

@implementation SeafSyncErrorLogger

/**
 * Returns the shared instance of the `SeafUIBridge`.
 *
 * @return The shared instance of the `SeafUIBridge`.
 */
+ (instancetype)sharedInstance {
    static SeafSyncErrorLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

/**
 * Handles the provided error, displaying an alert with the error description.
 *
 * @param error The error to be handled.
 */
- (void)log:(NSError *)error {
    if([error isKindOfClass:[SeafSyncQuotaExceededError class]]) {
        [self handleOutOfQuotaError:error];
        return;
    }
    
   // [[SeafUIBridge sharedInstance] alert:NSLocalizedString(@"Error", @"Seafile") message:[error localizedDescription]];
}

/**
 * Handles the provided error and registers it in the specified sync setting.
 *
 * @param error The error to be handled.
 * @param setting The sync setting to register the error in.
 */
- (void)log:(NSError *)error inSetting:(SeafSyncSettings *)setting {
    SeafSyncSettingsService *settingsService = [[SeafSyncSettingsService alloc] initWithConnection:setting.connection];
    [settingsService registerErrorIn:setting withError:error];
    
   // [self log:error];
}

/**
 * Handles the case where the error indicates that the quota has been exceeded.
 * Displays an alert with the option to view plans or cancel.
 *
 * @param error The error indicating quota exceeded.
 */
- (void)handleOutOfQuotaError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Seafile")  message:[error localizedDescription]  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"View plans", @"Seafile")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        // Handle the action to view plans
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancelar"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
        // Handle the action to cancel
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [[SeafUIBridge sharedInstance] presentViewController:alertController animated:YES completion:nil];
}

@end

