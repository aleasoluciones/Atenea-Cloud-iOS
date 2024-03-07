//
//  SeafRecoverySelectorViewController.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net)  on 30/10/23.
//

#import "SeafRecoverySelectorViewController.h"
#import "SeafRecoveryItem.h"
#import "UIImage+FileType.h"
#import "Debug.h"
#import "SeafTrashRecoverer.h"
#import "SeafAlertChangePlan.h"
#import "SeafRecoveryItemsProvider.h"
#import "SeafRecoveryDirentsProvider.h"
#import "SeafRecoveryFileFolderProvider.h"
#import "FileMimeType.h"
#import <objc/runtime.h>


/**
 View controller for displaying and recovering items from the trash.
 */
@interface SeafRecoverySelectorViewController ()

@property (nonatomic) SeafConnection *connection;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property NSArray<id<SeafRecoveryItem>> *availableItemsToRecover;
@property SeafTrashRecoverer *recoverer;
@property UIActivityIndicatorView *loadingView;
@property UILabel *placeholderView;
@property id<SeafRecoveryItemsProvider> provider;
@property UIBarButtonItem *confirmButtom;
@property  UIBarButtonItem *selectButtom;
@property  UIBarButtonItem *clearTrashButton;
@property  BOOL editable;
@property  BOOL clearable;
@end

@implementation SeafRecoverySelectorViewController

/**
 Initializes the view controller with a Seafile connection, a repository ID, and a folder path.
 
 @param connection The Seafile connection for which the recovery items are displayed.
 @param provider The recovery Items provider implementation
 @return An instance of SeafRecoverySelectorViewController.
 */
-(id) initWithConnection:(SeafConnection *) connection andProvider:(id<SeafRecoveryItemsProvider>) provider editable:(BOOL) editable clearable:(BOOL) clearable{
    
    self = [super init];
    
    if(self){
        self.connection = connection;
        self.provider = provider;
        self.recoverer = [[SeafTrashRecoverer alloc] initWitConnection:connection];
        self.editable = editable;
        self.clearable = clearable;
    }
    
    return self;
}

/**
 Called after the controller's view is loaded into memory.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Recovery", @"Seafile");
    
    [self registerCells];
    [self loadItemsToRecover];
    
    if(self.editable){
        [self renderNavigationButtons];
    }
}

/**
 Adds navigation buttons to the navigation bar.
 */
-(void)renderNavigationButtons {
    
    
    if (@available(iOS 13.0, *)) {
        
        self.confirmButtom = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.up.bin"] style:UIBarButtonItemStylePlain target:self action:@selector(confirmRecover)];
        
        self.selectButtom = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.square"] style:UIBarButtonItemStylePlain target:self action:@selector(activateSelect)];
        
        
 
            self.clearTrashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"trash.slash"] style:UIBarButtonItemStylePlain target:self action:@selector(clearTrash)];
        
        
    } else {
        
        self.confirmButtom = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Recover", @"Seafile") style:UIBarButtonItemStylePlain target:self action:@selector(confirmRecover)];
        
        self.selectButtom = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Select", @"Seafile") style:UIBarButtonItemStylePlain target:self action:@selector(activateSelect)];
        
    
            self.clearTrashButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Clear", @"Seafile") style:UIBarButtonItemStylePlain target:self action:@selector(clearTrash)];
        
    }
    
    if(self.clearable){
        self.navigationItem.rightBarButtonItems = @[ self.confirmButtom,self.selectButtom, self.clearTrashButton];
    }
    else{
        self.navigationItem.rightBarButtonItems = @[ self.confirmButtom,self.selectButtom];
    }
    
    [self updateRightBarButtonVisibility];
}



/**
 Loads items to recover based on the repository and folder path.
 */
-(void) loadItemsToRecover{
    [self showLoadingView];
    
    [self.provider getItems:^(NSArray<id<SeafRecoveryItem>> * _Nonnull items) {
        
        [self dismissLoadingView];
        self.availableItemsToRecover = items;
        [self displayEmptyTrashViewIfNeeded];
        [self.tableView reloadData];
    }];
}

- (void)activateSelect{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if(self.tableView.editing == FALSE){
        [self deselectRows];
        self.clearable = TRUE;
       
    }
    else{
        self.clearable = FALSE;
    }
    
    [self renderNavigationButtons];
    
}

- (void)clearTrash{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm", @"Seafile")  message:NSLocalizedString(@"Remove items from trash?", @"Seafile")  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Remove"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
        [self removeTrashItems];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
        //Do nothing
    }];
    
    [alertController addAction:continueAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



-(void) deselectRows{
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedRows) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    [self updateRightBarButtonVisibility];
    
}

/**
 Confirms the recovery of selected items.
 */
- (void)confirmRecover{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm", @"Seafile")  message:NSLocalizedString(@"Recover selected items?", @"Seafile")  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Recover"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
        [self recoverSelectedTableItems];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
        //Do nothing
    }];
    
    [alertController addAction:continueAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 Registers cells for the table view.
 */
-(void) registerCells{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}



-(void) navigateToChildFolder:(id<SeafRecoveryItem>) parent{
    
    if(parent.recoveryItemType != SeafRecoveryItemTypeRepository){
        
        if(self.tableView.editing == FALSE){
            [self deselectRows];
        }
        
        SeafRecoverySelectorViewController *controller = [[SeafRecoverySelectorViewController alloc] initWithConnection:self.connection andProvider:[[SeafRecoveryDirentsProvider alloc] initWithConnection:self.connection andParentDeletion:parent] editable:FALSE clearable:FALSE];
        controller.delegate = self.delegate;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

/**
 Called when a row is selected in the table view.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self updateRightBarButtonVisibility];
    
    id<SeafRecoveryItem> itemToRecover =[self.availableItemsToRecover objectAtIndex:indexPath.row];
    if([itemToRecover isDir] && self.tableView.editing == FALSE){
        [self navigateToChildFolder:itemToRecover];
    }
}



/**
 Called when a row is deselected in the table view.
 */
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self updateRightBarButtonVisibility];
}

/**
 Returns the editing style for a given row in the table view.
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone; // Prevents delete buttons from appearing
}

/**
 Updates the visibility of the right bar button based on the selected rows.
 */
-(void) updateRightBarButtonVisibility{
    if(self.tableView.indexPathsForSelectedRows.count >0){
        self.confirmButtom.enabled = true;
        return;
    }
    self.confirmButtom.enabled = false;
}

/**
 Returns the number of rows in the specified section of the table view.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableItemsToRecover count];
}

/**
 Asks the data source for a cell to insert in a particular location of the table view.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    id<SeafRecoveryItem> itemToRecover = [self.availableItemsToRecover objectAtIndex:indexPath.row];
    
    if(itemToRecover.isDir){
        cell.imageView.image = [UIImage imageForMimeType:nil ext:@"text-directory"];
        
    }else{
        cell.imageView.image = [UIImage imageForMimeType:[FileMimeType mimeType:[itemToRecover fullPath]] ext:nil];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = itemToRecover.name;
    cell.accessoryType = [itemToRecover isDir] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}

/**
 Recovers the selected items from the trash.
 */
-(void) recoverSelectedTableItems{
    NSMutableArray<id<SeafRecoveryItem>> *itemsToRecover = [self itemsToRecover];
    
    [self.recoverer refreshQuota:^{
        if([self.recoverer quotaAvailableSpaceForItems:itemsToRecover]){
            [itemsToRecover enumerateObjectsUsingBlock:^(id<SeafRecoveryItem> itemToRecover, NSUInteger idx, BOOL * _Nonnull stop) {
                [self recoverItem:itemToRecover];
            }];
        }
        else{
            [SeafAlertChangePlan showAlert: NSLocalizedString(@"ACCOUNT_QUOTA_EXCEEDED_MSG", @"Seafile") into:self];
        }
    }];
}


-(void) removeTrashItems{
    if(self.availableItemsToRecover.count > 0){
        NSString *repoId =  self.availableItemsToRecover[0].repositoryId;
        [self.recoverer clearTrash:repoId callback:^(BOOL success) {
            [self loadItemsToRecover];
        }];
    }
}

/**
 Gets the selected items to recover.
 */
- (NSMutableArray<id<SeafRecoveryItem>> *) itemsToRecover{
    NSMutableArray<id<SeafRecoveryItem>> *selectedItems = [[NSMutableArray alloc] initWithCapacity:[[self.tableView indexPathsForSelectedRows] count]];
    
    [[self.tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        [selectedItems addObject:[self.availableItemsToRecover objectAtIndex:indexPath.row]];
    }];
    
    return selectedItems;
}

/**
 Recovers an individual item from the trash.
 */
-(void) recoverItem:(id<SeafRecoveryItem>) item{
    [self showLoadingView];
    
    [self.recoverer recover: item  callback:^(SeafRecoveryResult result) {
        [self dismissLoadingView];
        
        switch(result){
            case SeafRecoveryResultSuccess:{
                
                //TODO: Debounce?
                if(self.delegate){
                    [self.delegate onRecovery];
                }
                [self dismissViewControllerAnimated:YES completion:nil];

                break;
            }
                
            case SeafRecoveryResultErrorQuota:{
                [SeafAlertChangePlan showAlert: NSLocalizedString(@"ACCOUNT_QUOTA_EXCEEDED_MSG", @"Seafile") into:self];
                break;
            }
                
            default:{
                return;
            }
        }
    }];
}

/**
 Displays the empty trash view if needed.
 */
-(void) displayEmptyTrashViewIfNeeded{
    if(self.availableItemsToRecover.count == 0){
        [self addEmptyTrashView];
        return;
    }
    [self removeEmptyTrashView];
}

/**
 Adds an empty trash view as the background.
 */
-(void) addEmptyTrashView{
    if(self.placeholderView == nil){
        self.placeholderView = [[UILabel alloc] initWithFrame:self.view.bounds];
        self.placeholderView.text = NSLocalizedString(@"EMPTY_TRASH", @"Seafile");
        self.placeholderView.textAlignment = NSTextAlignmentCenter;
    }
    
    [self.placeholderView removeFromSuperview];
    self.tableView.backgroundView = self.placeholderView;
}

/**
 Removes the empty trash view from the background.
 */
-(void) removeEmptyTrashView{
    if(self.placeholderView == nil){
        [self.placeholderView removeFromSuperview];
    }
}

/**
 Displays a loading view.
 */
- (void)showLoadingView
{
    if (!self.loadingView) {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingView.color = [UIColor darkTextColor];
        self.loadingView.hidesWhenStopped = YES;
        [self.view addSubview:self.loadingView];
    }
    
    self.loadingView.center = self.view.center;
    self.loadingView.frame = CGRectMake((self.view.frame.size.width-self.loadingView.frame.size.width)/2, (self.view.frame.size.height-self.loadingView.frame.size.height)/2, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
    [self.loadingView startAnimating];
}

/**
 Dismisses the loading view.
 */
- (void)dismissLoadingView
{
    [self.loadingView stopAnimating];
}

@end
