// AlertPrivacyPolicy.m

#import "AlertPrivacyPolicy.h"

@implementation AlertPrivacyPolicy

    UIAlertAction *acceptAction;

+ (void)showPrivacyPolicyAlertFromViewController:(UIViewController *)viewController  accepted:(void (^)(void))acceptedCallback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@" " message:@" " preferredStyle:UIAlertControllerStyleAlert];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 30, 200, 40)];
    textView.editable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    textView.backgroundColor = [UIColor clearColor];
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0;
    NSString *privacyPolicyText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"accept", @"Seafile"), NSLocalizedString(@"policy_privacy", @"Seafile")];

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:privacyPolicyText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];

    [attributedText addAttribute:NSLinkAttributeName value:NSLocalizedString(@"url_privacy", @"Seafile") range:[privacyPolicyText rangeOfString:NSLocalizedString(@"policy_privacy", @"Seafile")]];
    [attributedText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[privacyPolicyText rangeOfString:NSLocalizedString(@"policy_privacy", @"Seafile")]];

    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[privacyPolicyText rangeOfString:NSLocalizedString(@"policy_privacy", @"Seafile")]];

    textView.attributedText = attributedText;
    textView.editable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    textView.textColor = [UIColor blackColor];
    [alertController.view addSubview:textView];

   // CGFloat textWidth = textView.bounds.size.width;
    CGFloat checkboxWidth = 16.0;
//    CGFloat totalWidth = textWidth + checkboxWidth + 10;

    CGRect textViewFrame = textView.frame;
    textViewFrame.origin.x = 50 + checkboxWidth / 2;
    textView.frame = textViewFrame;

    CGRect checkboxRect = CGRectMake(CGRectGetMinX(textView.frame) - checkboxWidth - 10, CGRectGetMinY(textView.frame) , checkboxWidth, checkboxWidth);
    UIButton *checkboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkboxButton.frame = checkboxRect;
    checkboxButton.layer.borderWidth = 1.0;
    checkboxButton.layer.borderColor = [UIColor blackColor].CGColor;
    [checkboxButton addTarget:self action:@selector(checkboxTapped:) forControlEvents:UIControlEventTouchUpInside];
    [alertController.view addSubview:checkboxButton];

  acceptAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"accept",@"Seafile") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        if (acceptedCallback) {
            acceptedCallback();
        }
    }];
    acceptAction.enabled = NO;

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"Seafile") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];

    [alertController addAction:acceptAction];
    [alertController addAction:cancelAction];

    [viewController presentViewController:alertController animated:YES completion:nil];

}


+ (void)checkboxTapped:(UIButton *)sender {
    sender.selected = !sender.isSelected;
  
    if (sender.isSelected) {
        UIImage *checkedImage = [UIImage imageNamed:@"checkmark"];
        [sender setImage:checkedImage forState:UIControlStateNormal];
        acceptAction.enabled = YES;

    } else {
        [sender setImage:nil forState:UIControlStateNormal];
        acceptAction.enabled = NO;
    }
}


@end
