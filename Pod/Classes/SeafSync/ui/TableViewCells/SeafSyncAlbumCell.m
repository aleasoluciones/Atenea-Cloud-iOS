//
//  SeafSyncAlbumCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import "SeafSyncAlbumCell.h"
#import "SeafSyncAlbumSelectorViewController.h"

@interface SeafSyncAlbumCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *albumNameLabel;

- (IBAction)onTouch:(id)sender;

@property (nonatomic) SeafSyncAlbumCellCallback callback;


@end


@implementation SeafSyncAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (IBAction)onTouch:(id)sender {
    
    UINavigationController *nestedNavigationController = [[UINavigationController alloc] init];
    
    SeafSyncAlbumSelectorViewController *albumSelector = [[SeafSyncAlbumSelectorViewController alloc] initWithDelegate:self];
    
    [nestedNavigationController pushViewController:albumSelector animated:YES];
    
    [self.window.rootViewController presentViewController:nestedNavigationController animated:YES completion:nil];
    return;
    
   
   // [self.window.rootViewController presentViewController:albumSelector animated:YES completion:nil];
    
}

- (void) setTitle:(NSString *) title{
    self.titleLabel.text = title;
}


- (void) onAlbumSelected:(SeafSyncAlbumCellCallback) callback{
    self.callback = callback;
}


- (void) setAlbum:(NSString *) albumName{
    self.albumNameLabel.text = albumName;
}

//Delegate SeafSyncAlbumSelectorViewControllerDelegate
-(void) onSelectAlbum:(PHAssetCollection *) assetCollection{
    [self setAlbum:assetCollection.localizedTitle];
    if(self.callback){
        self.callback(assetCollection.localizedTitle);
    }
}

@end
