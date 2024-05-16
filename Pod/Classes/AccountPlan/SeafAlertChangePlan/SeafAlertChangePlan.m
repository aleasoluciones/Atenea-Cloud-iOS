//
//  SeafAlertChangePlan.m
//  Seafile
//
//  Created by apps meytel on 11/10/23.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
#import "SeafAlertChangePlan.h"
#import "SeafUIBridge.h"
#import "Support4k.h"
#import "SupportExtension.h"
#import "SeafUploadSize.h"
#import "SeafEnoughQuota.h"
#import "Support4kPreview.h"


@implementation SeafAlertChangePlan


+ (void)showAlertWithFilterStrategy:(id<SeafFileFilterStrategy>) filterStrategy; {
      NSString *message = nil;
      
    if ([filterStrategy isKindOfClass:[Support4k class]]  || [filterStrategy isKindOfClass:[Support4kPreview class]]) {
          message = NSLocalizedString(@"ACCOUNT_4K_RESTRICTED_MSG", @"Seafile");
      } else if ([filterStrategy isKindOfClass:[SupportExtension class]]) {
          message = NSLocalizedString(@"ACCOUNT_EXTENSION_RESTRICTED_MSG", @"Seafile");
      } else if ([filterStrategy isKindOfClass:[SeafUploadSize class]]) {
          message = NSLocalizedString(@"ACCOUNT_UPLOAD_SIZE_LIMIT_MSG", @"Seafile");
      } else if ([filterStrategy isKindOfClass:[SeafEnoughQuota class]]) {
          message = NSLocalizedString(@"ACCOUNT_QUOTA_EXCEEDED_MSG", @"Seafile");
      }
    
    [self showAlert:message];

}


+ (void) showAlert: (NSString *_Nonnull)message into:(UIViewController *) controller{
    [controller presentViewController:[self createAlertController: message into:controller] animated:YES completion:nil];
}


+ (void)showAlert: (NSString*)message {
    [[SeafUIBridge sharedInstance] presentViewController:[self createAlertController:message into:[SeafUIBridge sharedInstance].viewController] animated:YES completion:nil];
}


+(UIAlertController *) createAlertController:(NSString *) message into:(UIViewController *) viewController{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Change of plan", @"Seafile")
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];




    UIAlertAction *changePlanAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Change plan", @"Seafile")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                                NSURL *url = [NSURL URLWithString:NSLocalizedString(@"url_contact", @"Seafile")];
                                                                SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
                                                                [viewController presentViewController:safariViewController animated:YES completion:nil];
                                                           }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Seafile")

                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alertController addAction:changePlanAction];
    [alertController addAction:cancelAction];
    
    return alertController;
}

@end




