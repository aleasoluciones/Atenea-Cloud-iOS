//
//  AlertPrivacyPolicy.h
//  Seafile
//
//  Created by apps meytel on 8/3/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertPrivacyPolicy : NSObject

+ (void)showPrivacyPolicyAlertFromViewController:(UIViewController *)viewController  accepted:(void (^)(void))acceptedCallback;

@end

NS_ASSUME_NONNULL_END
