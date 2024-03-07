//
//  SeafSyncDirSelectorCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 9/10/23.
//

#import "SeafSyncDirSelectorCell.h"

@interface SeafSyncDirSelectorCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *folderLabel;

- (IBAction)onTouch:(id)sender;

@property (nonatomic) SeafSyncDirSelectorCellCallback callback;
@property (nonatomic) SeafConnection *_connection;


@end


@implementation SeafSyncDirSelectorCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (IBAction)onTouch:(id)sender {
    [self navigateToDirSelectorController];
}

- (void) setConnection:(SeafConnection *) connection{
    self._connection = connection;
}

-(void) navigateToDirSelectorController{
    
    if(self._connection == nil){
        NSLog(@"ERROR: Connection is NULL. Please, set the connection via 'setConnection' method");
        return;
    }
    
    UINavigationController *nestedNavigationController = [[UINavigationController alloc] init];
    
    SeafSyncDirSelectorViewController *dirSelector = [[SeafSyncDirSelectorViewController alloc] initWithConnection:self._connection];
    [dirSelector setDelegate:self];
    
    
    [nestedNavigationController pushViewController:dirSelector animated:YES];
    
    [self.window.rootViewController presentViewController:nestedNavigationController animated:YES completion:nil];
    return;
}

-(void) onSelectDirecory:(SeafDir *) directory{

    if(self.callback){
        self.callback(directory);
        [self setDirectoryPath:[directory path]];
    }
}


- (void) onDirectorySelected:(SeafSyncDirSelectorCellCallback) callback{
    self.callback = callback;
}

- (void) setTitle:(NSString *) title{
    self.titleLabel.text = title;
}

- (void) setDirectoryPath:(NSString *) directoryPath{
    self.folderLabel.text = directoryPath;
}


@end
