//
//  SeafSyncDeviceFolderCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import "SeafSyncDeviceFolderCell.h"
#import "SeafSyncUserInterfaceUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface SeafSyncDeviceFolderCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *folderLabel;

- (IBAction)onTouch:(id)sender;

@end



@implementation SeafSyncDeviceFolderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.folderLabel.text = NSLocalizedString(@"Select source folder", @"Seafile");
}


- (IBAction)onTouch:(id)sender {
    UIResponder *responder = self;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    UIViewController *vc = (UIViewController *)responder;

    if ([self.delegate respondsToSelector:@selector(seafSyncDeviceFolderCellDidRequestFolderSelectionFromController:forCell:)]) {
        [self.delegate seafSyncDeviceFolderCellDidRequestFolderSelectionFromController:vc forCell:self];
    }
}

- (void) setTitle:(NSString *) title{
    self.titleLabel.text = title;
}

- (void) setFolderURL:(NSURL *) folderURL{
    self.folderLabel.text = [folderURL lastPathComponent];
}

-(void) setActiveState:(BOOL) active{
    
    if(active){
        self.contentView.alpha = 1;
        self.userInteractionEnabled = TRUE;
        return;
    }
    
    self.contentView.alpha = 0.1;
    self.userInteractionEnabled = FALSE;
}

@end

