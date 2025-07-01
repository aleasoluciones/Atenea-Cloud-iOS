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

@property (nonatomic) SeafSyncDeviceFolderCellCallback callback;


@end



@implementation SeafSyncDeviceFolderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.folderLabel.text = NSLocalizedString(@"Select source folder", @"Seafile");
}

- (IBAction)onTouch:(id)sender {
    [self presentDocumentPicker];
}


- (void) onFolderSelected:(SeafSyncDeviceFolderCellCallback) callback{
    self.callback = callback;
}

- (void) setTitle:(NSString *) title{
    self.titleLabel.text = title;
}

- (void) setFolderURL:(NSURL *) folderURL{
    self.folderLabel.text = [folderURL lastPathComponent];
}

-(void) presentDocumentPicker{
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeFolder] inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    [self.window.rootViewController presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    
    NSError *error;
    NSURL *url = [urls firstObject];

    if(url){
        
        if ([[NSFileManager defaultManager] ubiquityIdentityToken]) {
            
            [url startAccessingSecurityScopedResource];
            
            NSData* bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
            
            
            [self setFolderURL:url];
            
            if(self.callback){
                self.callback(bookmark);
            }
            
            [url stopAccessingSecurityScopedResource];
        }
    }
}

@end

