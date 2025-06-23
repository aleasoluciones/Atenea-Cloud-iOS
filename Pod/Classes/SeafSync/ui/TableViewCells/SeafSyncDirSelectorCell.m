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
    NSLog(@"DIR FOLDER CELL - onTouch ejecutado");
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
    
    UIViewController *presentingViewController = [self findViewController];
    
    if (!presentingViewController) {
        NSLog(@"ERROR: No se pudo encontrar el view controller para presentar el selector");
        return;
    }
    
    UINavigationController *nestedNavigationController = [[UINavigationController alloc] init];
    
    SeafSyncDirSelectorViewController *dirSelector = [[SeafSyncDirSelectorViewController alloc] initWithConnection:self._connection];
    [dirSelector setDelegate:self];
    
    [nestedNavigationController pushViewController:dirSelector animated:YES];
    
    [presentingViewController presentViewController:nestedNavigationController animated:YES completion:nil];
}

// MÉTODO AUXILIAR: Encontrar el view controller que contiene esta celda
- (UIViewController *)findViewController {
    UIResponder *responder = self;
    while (responder) {
        responder = [responder nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
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
