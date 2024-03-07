//
//  SyncSettingDetailsViewController.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import "SyncSettingDetailsViewController.h"
#import "SeafSyncSettings.h"
#import "SeafSyncSettingsService.h"
#import "SeafSyncCheckBoxCell.h"
#import "SeafSyncDateCell.h"
#import "SeafSyncSegmentedCell.h"
#import "SeafSyncDeviceFolderCell.h"
#import "SeafSyncAlbumCell.h"
#import "SeafSyncUtils.h"
#import "SeafSyncDirSelectorCell.h"
#import "SeafSyncSelectorCell.h"
#import "SeafSyncErrorFactory.h"
#import "SeafSyncEnqueuerFactory.h"
#import "SeafQuotaSupervisor.h"
#import "SeafUIBridge.h"
#import "SeafPlanUser.h"
#import "SeafConnection+UserPlan.h"
#import "SeafPlanBasic.h"
#import "SeafAlertChangePlan.h"
#import "SeafSyncSelectorCellDataItem.h"
#import "SeafSyncSelectorCellDataItemProtocol.h"
#import "SeafSyncBaseUITableViewCell.h"
#import <CoreLocation/CoreLocation.h>

@class SeafEnqueuerProtocol;

@interface SyncSettingDetailsViewController ()

/**
 * @brief Table view for displaying synchronization setting details.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 * @brief Synchronization setting details.
 */
@property (nonatomic) SeafSyncSettings *settings;

/**
 * @brief Synchronization manager instance.
 */
@property (nonatomic) SeafSyncronizer *syncronizer;


@property (nonatomic) SeafSyncSettingsService *settingsService;

@property UIActivityIndicatorView *loadingView;

@property BOOL isEditingSetting;

@end

@implementation SyncSettingDetailsViewController

/**
 * @brief Initializes a new instance of SyncSettingDetailsViewController.
 *
 * @param settings The SeafSyncSettings object for which details are displayed.
 * @param syncronizer The SeafSyncronizer object managing synchronization settings.
 * @return An initialized instance of SyncSettingDetailsViewController.
 */
-(id) initWithSettings:(SeafSyncSettings *) settings andSyncronizer:(SeafSyncronizer *) syncronizer{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if(self){
        self.settings = settings;
        self.settings.accountId = [[syncronizer getConnectionInUse] username];
        self.syncronizer = syncronizer;
        self.settingsService = [[SeafSyncSettingsService alloc] initWithConnection:[self.syncronizer getConnectionInUse]];
        self.isEditingSetting =  self.settings.targetId != nil;
    }
    return self;
}

/**
 * @brief Called after the controller's view is loaded into memory.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCells];
    [self addRightButtons];
    
    // Table settings
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //Controller settings
    self.title = NSLocalizedString(@"Edit backup settings", @"Seafile");
}

/**
 * @brief Registers custom cells for the table view.
 */
-(void) registerCells{
    
    //Checkbox cells
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SeafSyncCheckBoxCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SeafSyncCheckBoxCell class])];
    
    //Date picker cells
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SeafSyncDateCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SeafSyncDateCell class])];
    
    //Segments cells
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SeafSyncSegmentedCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SeafSyncSegmentedCell class])];
    
    //Folder selector cells
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SeafSyncDeviceFolderCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SeafSyncDeviceFolderCell class])];
    
    //Cloud Directory selector cells
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SeafSyncDirSelectorCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SeafSyncDirSelectorCell class])];
    
    //Album selector cells
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SeafSyncAlbumCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SeafSyncAlbumCell class])];
    
    //Album selector cells
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SeafSyncSelectorCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SeafSyncSelectorCell class])];
    
    //Default cells
    [self.tableView registerClass:[SeafSyncBaseUITableViewCell class] forCellReuseIdentifier:NSStringFromClass([SeafSyncBaseUITableViewCell class])];
}

/**
 * @brief Adds right bar buttons for saving and removing synchronization settings.
 */
-(void)addRightButtons {
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Save button. Always visible
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                     target:self
                                                                     action:@selector(saveSetting)]];
    
    // Remove setting button
    // Only add to right buttons if we are editing an existing setting
    if(self.isEditingSetting){
        [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                         target:self
                                                                         action:@selector(comfirmRemove)]];
    }
    
    self.navigationItem.rightBarButtonItems = buttons;
}

/**
 * @brief Saves the current synchronization setting.
 */
-(void) saveSetting{
    
    [self showLoadingView];
    
    if(![self validateSettingsFields]){
        [self dismissLoadingView];
        return;
    }
    
    
    [self requestLocationPermissionIfNeeded];
    
    
    //The setting is inactive, so we do not check storage or queue, just save&go
    if(FALSE == self.settings.active){
        [self storeSetting];
        [self dismissLoadingView];
        [self dismiss];
        return;
    }
    
    //The setting is active. Check space.
    //Save in other thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //If available space just store it
        if([self availableSpaceForThisSetting]){
            [self storeSetting];
            [self dismissLoadingView];
            [self dismiss];
            return;
        }
        
        //If not enough space,
        [self dismissLoadingView];
        [self askAndIfContinue:^{
            [self storeSetting];
            [self dismiss];
        }];
        
    });
    
    
    
}


/**
 * @brief Validates the settings fields to ensure that the necessary criteria are met.
 *
 * This method checks if the targetId is set and not nil. If it's nil, it displays an error alert.
 * It also checks if either repoId or accountId is set, and if so, it displays an error alert.
 *
 * @return Returns TRUE if the settings fields are valid, FALSE otherwise.
 */
- (BOOL)validateSettingsFields {
    
    if (self.settings.resourceId == nil && self.settings.sourceType != Gallery) {
        [[SeafUIBridge sharedInstance] alert:NSLocalizedString(@"Error", @"Seafile") message:NSLocalizedString(@"Please select the source", @"Seafile")];
        return FALSE;
    }
    
    if (self.settings.targetId == nil) {
        [[SeafUIBridge sharedInstance] alert:NSLocalizedString(@"Error", @"Seafile") message:NSLocalizedString(@"Please select the target folder", @"Seafile")];
        return FALSE;
    }
    
    if([self settingWithSameTargetSourceExists]){
        [[SeafUIBridge sharedInstance] alert:NSLocalizedString(@"Error", @"Seafile") message:NSLocalizedString(@"Same source & target folder already exists in other backup setting", @"Seafile")];
        return FALSE;
    }
    
    
    return TRUE;
}

/**
 Checks if a SeafSyncSettings object with the same target and source already exists.
 
 This method uses a predicate to check if a SeafSyncSettings object with the same target ID
 and source exists in the settings collection.
 
 @return YES if a matching SeafSyncSettings object exists; otherwise, NO.
 
 */

-(BOOL) settingWithSameTargetSourceExists{
    NSPredicate *filter =[NSPredicate predicateWithBlock:^BOOL(SeafSyncSettings *setting, NSDictionary<NSString *,id> * _Nullable bindings) {
        return
        // [setting.accountId isEqualToString:self.settings.accountId] && //Same account. No necesary. Already filtered
        [setting.repoId isEqualToString:self.settings.repoId] && //Same repo
        [setting.targetId isEqualToString:self.settings.targetId] && //Same target folder in repo
        [[self getStringSource:setting] isEqualToString:[self getStringSource:self.settings]]; //Same source in device
    }];
    
    NSArray *results = [self.settingsService find:filter];
    
    //Its me?
    //If I the ViewController setting´s identifier and is not the same as the matched setting in filter means theres another setting with same source&target
    //On creation will be never be the same, because has no identifier
    //On update could be the same or diferent
    SeafSyncSettings *matchedSetting = [results firstObject];
    if([matchedSetting.identifier isEqualToString:self.settings.identifier ]){
        return false;
    }
    
    
    return [results count] > 0;
}

/**
 Retrieves the source string from a SeafSyncSettings object.
 
 This method determines the source string based on the source type of the SeafSyncSettings object.
 If the source type is Folder, it uses SeafSyncUtils to get the URL from the bookmark;
 otherwise, it returns the resource ID directly.
 
 @param setting The SeafSyncSettings object for which to retrieve the source string.
 @return The source string based on the source type of the SeafSyncSettings object.
 */
-(NSString *) getStringSource:(SeafSyncSettings *) setting{
    
    if(setting.sourceType == Folder){
        return setting.fullSourceURL;
    }
    
    if(setting.sourceType == Gallery){
        return @"gallery";
    }
    
    return [setting.resourceId stringValue];
}



/**
 * @brief Saves the current synchronization setting.
 */
-(void) storeSetting{
    [self.syncronizer add:self.settings];
}


-(void) dismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}


-(BOOL) availableSpaceForThisSetting{
    
    id<SeafEnqueuerProtocol> uploader = [SeafSyncEnqueuerFactory getEnqueuerFor:[self.syncronizer getConnectionInUse] settings:self.settings];
    long long estimatedSize = [uploader estimatedUploadSizeInBytes];
    
    //Check if available space in quota
    SeafQuotaSupervisor *quotaSupervisor = [SeafQuotaSupervisor sharedInstanceFor:[self.syncronizer getConnectionInUse]];
    return [quotaSupervisor isEnoughSpaceToUpload:estimatedSize];
}



- (void)askAndIfContinue:(void (^)(void)) onContinue{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Quota Exceeded", @"Seafile")  message:NSLocalizedString(@"There is not enough space in your cloud to store all the files. If you continue, some files will not be backed up.", @"Seafile")  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *plansAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upgrade plan", @"Seafile")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
        // Handle the action to view plans
    }];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Continue anyway"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
        onContinue();
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
        //Do nothing
    }];
    
    [alertController addAction:plansAction];
    [alertController addAction:continueAction];
    [alertController addAction:cancelAction];
    
    [[SeafUIBridge sharedInstance] presentViewController:alertController animated:YES completion:nil];
}


- (void)comfirmRemove{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm", @"Seafile")  message:NSLocalizedString(@"Remove this settings?", @"Seafile")  preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Remove"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
        [self removeSetting];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
        //Do nothing
    }];
    
    [alertController addAction:continueAction];
    [alertController addAction:cancelAction];
    
    [[SeafUIBridge sharedInstance] presentViewController:alertController animated:YES completion:nil];
}


/**
 * @brief Removes the current synchronization setting.
 */
-(void) removeSetting{
    [self.syncronizer remove:self.settings];
    [self.navigationController popViewControllerAnimated:YES];
}



/**
 * @brief Returns the number of rows in the specified section.
 *
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return The number of rows in the section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == ERROR_SECTION){
        return (self.settings.lastRunError != SeafSyncErrorNoError) ? 1 : 0;
    }
    
    if(section == ACTIVE_SECTION){
        return 1;
    }
    
    if(section == TARGET_SOURCE_SECTION){
        return 2;
    }
    
    if(section == SETTINGS_SECTION){
        return 3;
    }
    
    if(section == EXPIRATIONS_SECTION){
        
        if(FALSE == [self userPlanSupportCustomizableBackups]){
            //0 => Upgrade plan cell
            return 1;
        }
        
        if( self.settings.lifeTime == SeafSyncLifetimeTypeTemporal){
            //0 => Permanent or Temporal
            //1 => Available until
            //2 => Remove files on expiration
            return 3;
        }
        
        if( self.settings.lifeTime == SeafSyncLifetimeTypePermanent){
            //0 => Permanent or Temporal
            //1 => Temporal Availability
            //2 => Maintain files in cloud for..
            
            return [self temporalAvailiabilityEnabledIPermanentSetting] ? 3 : 2;
        }
    }
    
    
    return  0;
}

/**
 * @brief Asks the data source for the number of sections in the table view.
 *
 * @param tableView An object representing the table view requesting this information.
 * @return The number of sections in tableView.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Error section => 0
    // Global settings = > 1
    // Section 1 => Source + Target
    // Sections 2 => Wifi, Incremental || Full, Upload Videos...
    // Sections 3 => Expirations...
    
    return 5;
}

/**
 * @brief Asks the data source for a cell to insert in a particular location of the table view.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SeafSyncBaseUITableViewCell *cell;
    
    switch (indexPath.section) {
        case ERROR_SECTION:
            cell = (SeafSyncBaseUITableViewCell *)[self cellForErrorSection:tableView atIndexPath:indexPath];
            break;
        case ACTIVE_SECTION:
            cell = (SeafSyncBaseUITableViewCell *)[self cellForActiveSection:tableView atIndexPath:indexPath];
            break;
        case TARGET_SOURCE_SECTION:
            cell = (SeafSyncBaseUITableViewCell *)[self cellForTargetSection:tableView atIndexPath:indexPath];
            break;
        case EXPIRATIONS_SECTION:
            cell = (SeafSyncBaseUITableViewCell *)[self cellForExpirationSection:tableView atIndexPath:indexPath];
            break;
        default:
            cell = (SeafSyncBaseUITableViewCell *)[self cellForSettingsSection:tableView atIndexPath:indexPath];
            break;
    }
    
    //Only change state for the cell outside ACTIVE_SECTION (this section must be always active)
    if(indexPath.section == ACTIVE_SECTION){
        [cell setActiveState:TRUE];
        return cell;
    }
    
    //Expiraction section handles the active state on his own
    if(indexPath.section == EXPIRATIONS_SECTION){
        return cell;
    }
    
    //Any other section, inherits from active
    [cell setActiveState:self.settings.active];
    
    
    return cell;
    
}

- (UITableViewCell *)cellForActiveSection:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    SeafSyncCheckBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncCheckBoxCell class]) forIndexPath:indexPath];
    [cell setTitle:NSLocalizedString(@"Active", @"Seafile")];
    [cell setValue: self.settings.active];
    [cell onSwitchChange:^(BOOL value) {
        self.settings.active = value;
        [self.tableView reloadData];
    }];
    return cell;
}


- (UITableViewCell *)cellForErrorSection:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    SeafSyncBaseUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncBaseUITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = [[SeafSyncErrorFactory createFrom:self.settings.lastRunError] localizedDescription];
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.contentView.backgroundColor = UIColor.redColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
/**
 * @brief Configures and returns a cell for the target section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)cellForTargetSection:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:{
            return [self cellForSourceRow:tableView atIndexPath:indexPath];
        }
            
        default:{
            SeafSyncDirSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncDirSelectorCell class]) forIndexPath:indexPath];
            [cell setTitle: NSLocalizedString(@"Target folder", @"Seafile")];
            [cell setDirectoryPath:self.settings.targetId];
            [cell setConnection:[self.syncronizer getConnectionInUse]];
            [cell onDirectorySelected:^(SeafDir * _Nonnull directory) {
                self.settings.targetId = [directory path];
                self.settings.repoId = [directory repoId];
                
            }];
            
            return cell;
        }
    }
}

/**
 * @brief Configures and returns a cell for the source row in the target section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)cellForSourceRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    
    //Source => Folder
    if(self.settings.sourceType == Folder){
        SeafSyncDeviceFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncDeviceFolderCell class]) forIndexPath:indexPath];
        [cell setTitle: NSLocalizedString(@"Source folder", @"Seafile")];
        [cell setFolderURL:[SeafSyncUtils urlFromBookmark:self.settings.resourceId]];
        [cell onFolderSelected:^(NSData * _Nonnull bookmark) {
            self.settings.resourceId = bookmark;
            self.settings.fullSourceURL = [[SeafSyncUtils urlFromBookmark:bookmark] absoluteString];
        }];
        
        return cell;
    }
    
    //Source => Album
    if(self.settings.sourceType == Album){
        SeafSyncAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncAlbumCell class]) forIndexPath:indexPath];
        [cell setTitle: NSLocalizedString(@"Source album", @"Seafile")];
        [cell setAlbum:self.settings.resourceId];
        [cell onAlbumSelected:^(NSString * _Nonnull albumName) {
            self.settings.resourceId = albumName;
        }];
        
        return cell;
    }
    
    
    //Default. Source => Gallery
    SeafSyncBaseUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncBaseUITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"Gallery", @"Seafile");
    return cell;
}

/**
 * @brief Tells the delegate that the specified row is now selected.
 *
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path that identifies the selected row.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == TARGET_SOURCE_SECTION){
        return;
    }
    
    //User plan without customizable backup
    if(indexPath.section == EXPIRATIONS_SECTION && ! [self userPlanSupportCustomizableBackups]){
        [SeafAlertChangePlan showAlert: NSLocalizedString(@"ACCOUNT_PLAN_DISABLE_OPCION", @"Seafile") into:self];
    }
}




/**
 * Check if the user's plan supports customizable backups.
 *
 * @return YES if customizable backups are supported, NO otherwise.
 */
- (BOOL)userPlanSupportCustomizableBackups {
    // Retrieve the user's plan from the connection settings.
    SeafPlanUser *plan = self.settings.connection.getPlan;
    
    // Return whether customizable backups are supported based on the user's plan.
    return plan.customizableBackup;
}



/**
 * @brief Configures and returns a cell for the settings section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)cellForSettingsSection:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
            // Only wifi
        case 0: {
            SeafSyncCheckBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncCheckBoxCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"Wifi Only", @"Seafile")];
            [cell setValue: self.settings.uploadOnlyOverWifi];
            [cell onSwitchChange:^(BOOL value) {
                self.settings.uploadOnlyOverWifi = value;
            }];
            
            return cell;
            break;
        }
            
            // Upload video
        case 1: {
            SeafSyncCheckBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncCheckBoxCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"Upload Videos", @"Seafile")];
            [cell setValue: self.settings.uploadVideos];
            [cell onSwitchChange:^(BOOL value) {
                self.settings.uploadVideos = value;
            }];
            
            return cell;
            break;
        }
            
            // Mode (Incremental || Full)
        case 2: {
            SeafSyncSegmentedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncSegmentedCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"Sync mode", @"Seafile")];
            [cell setSegments:[[NSArray alloc] initWithObjects:NSLocalizedString(@"Full", @"Seafile"), NSLocalizedString(@"Incremental", @"Seafile"), nil]];
            [cell setSelectedSegmentIndex: (self.settings.mode == Full) ? 0 : 1];
            [cell onSegmentSelected:^(NSInteger selectedIndex) {
                if(selectedIndex == 1){
                    self.settings.mode = Incremental;
                    return;
                }
                self.settings.mode = Full;
            }];
            
            return cell;
            break;
        }
            
            
            // Unknown
        default:{
            SeafSyncBaseUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncBaseUITableViewCell class]) forIndexPath:indexPath];
            return cell;
            break;
        }
    }
}


/**
 * @brief Configures and returns a cell for the expiration section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)cellForExpirationSection:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    //No available
    if(FALSE == [self userPlanSupportCustomizableBackups]){
        SeafSyncBaseUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncBaseUITableViewCell class]) forIndexPath:indexPath];
        [cell.textLabel setText:NSLocalizedString(@"Upgrade your plan to unlock this feature", @"Seafile")];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        return cell;
    }
    
    switch (indexPath.row) {
            
        case 0:{
            SeafSyncSegmentedCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncSegmentedCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"Lifetime settings", @"Seafile")];
            [cell setSegments:[[NSArray alloc] initWithObjects:NSLocalizedString(@"Permanent", @"Seafile"), NSLocalizedString(@"Temporal", @"Seafile"), nil]];
            [cell setSelectedSegmentIndex: (self.settings.lifeTime == SeafSyncLifetimeTypeTemporal) ? 1 : 0];
            [cell onSegmentSelected:^(NSInteger selectedIndex) {
                if(selectedIndex == 1){
                    self.settings.lifeTime = SeafSyncLifetimeTypeTemporal;
                    [self.tableView reloadData];
                    return;
                }
                self.settings.lifeTime = SeafSyncLifetimeTypePermanent;
                [self.tableView reloadData];
            }];
            //[cell setActiveState:FALSE];
            [cell setActiveState:!self.isEditingSetting];
            return cell;
            break;
        }
            
        default:{
            
            if( self.settings.lifeTime == SeafSyncLifetimeTypeTemporal){
                return (SeafSyncBaseUITableViewCell *)[self cellForTemporalExpirationSubSection:tableView atIndexPath:indexPath];
            }
            else{
                return (SeafSyncBaseUITableViewCell *)[self cellForPermanentExpirationSubSection:tableView atIndexPath:indexPath];
            }
        }
    }
    
    //Expiration mode cannot be changed once created setting
    //[finalCell setActiveState:!self.isEditingSetting];
    
    
    
    
    // return  finalCell;
    
    
}


/**
 * @brief Configures and returns a cell for the expiration section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)cellForPermanentExpirationSubSection:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
        case 1: {
            SeafSyncCheckBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncCheckBoxCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"File expiration enabled", @"Seafile")];
            [cell setValue: [self temporalAvailiabilityEnabledIPermanentSetting]];
            [cell onSwitchChange:^(BOOL value) {
                self.settings.durationOfBackupFilesOnCloudInDays = value ? 1 : 0;
                [self.tableView reloadData];
            }];
            return cell;
            break;
        }
            
            // Expiration date
        case 2: {
            SeafSyncSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncSelectorCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"Expire files since upload date after", @"Seafile")];
            [cell setValues:[self availableExpirations]];
            [cell selectedItems:[self getSelectedExpirationValues]];
            [cell onValueChange:^(NSArray<id<SeafSyncSelectorCellDataItemProtocol>>  *selectedItems) {
                
                __block NSInteger daysToExpire = 1;
                [selectedItems enumerateObjectsUsingBlock:^(id<SeafSyncSelectorCellDataItemProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //This means:
                    // the days column values (first component un in picker) are:  1,2,3,4,5,6,7,8...31
                    // the scale column values (second component un in picker) are: days(value = 1), weeks (value = 7), months (value = 30), years(value is 365)
                    // so, if user selects " 3 | weeks " , the resulting total days will be => 3 * 7 => 21 days.
                    daysToExpire = daysToExpire * [obj.value integerValue];
                }];
                
                self.settings.durationOfBackupFilesOnCloudInDays = daysToExpire;
                [self.tableView reloadData];
            }];
            
            return cell;
            break;
        }
            
            // Unknown
        default:{
            SeafSyncBaseUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncBaseUITableViewCell class]) forIndexPath:indexPath];
            return cell;
            break;
        }
    }
    
}


/**
 * @brief Configures and returns a cell for the expiration section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)cellForTemporalExpirationSubSection:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.row) {
            // Expiration date
        case 1: {
            SeafSyncDateCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncDateCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"Active until", @"Seafile")];
            [cell setDate: self.settings.availableUntilDate];
            [cell onDateChange:^(NSDate * _Nonnull value) {
                self.settings.availableUntilDate = value;
            }];
            
            return cell;
            break;
        }
        case 2: {
            SeafSyncCheckBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncCheckBoxCell class]) forIndexPath:indexPath];
            [cell setTitle:NSLocalizedString(@"Remove cloud files when expired", @"Seafile")];
            [cell setValue: self.settings.deleteFilesOnExpire];
            [cell onSwitchChange:^(BOOL value) {
                self.settings.deleteFilesOnExpire = value;
            }];
            return cell;
            break;
        }
            
            // Unknown
        default:{
            SeafSyncBaseUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SeafSyncBaseUITableViewCell class]) forIndexPath:indexPath];
            return cell;
            break;
        }
    }
    
}


/**
 * @brief Asks the delegate for the title of the header of the specified section of the table view.
 *
 * @param tableView A table-view object asking for the title.
 * @param section An index number identifying a section in tableView.
 * @return A string to use as the title of the section header.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case ERROR_SECTION:
            return @"";
            break;
        case ACTIVE_SECTION:
            return @"Global state";
            break;
        case TARGET_SOURCE_SECTION:
            return NSLocalizedString(@"Source and target", @"Seafile");
            break;
            
        case EXPIRATIONS_SECTION:
            return NSLocalizedString(@"Backup expirations", @"Seafile");
            break;
        default:
            return NSLocalizedString(@"Backup settings", @"Seafile");
            break;
    }
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(ERROR_SECTION == section){
        return 0;
    }
    
    return 10;
}
/**
 * @brief Asks the delegate for the height to use for the header of a particular section.
 *
 * @param tableView A table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return A nonnegative floating-point value that specifies the height (in points) of the header for section.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(ERROR_SECTION == section){
        return 0;
    }
    
    return 50;
}


/**
 * @brief Shows the loading view with an activity indicator.
 */
- (void)showLoadingView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.loadingView) {
            self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.loadingView.color = [UIColor darkTextColor];
            self.loadingView.hidesWhenStopped = YES;
            [self.view addSubview:self.loadingView];
        }
        
        self.loadingView.center = self.view.center;
        self.loadingView.frame = CGRectMake((self.view.frame.size.width - self.loadingView.frame.size.width) / 2, (self.view.frame.size.height - self.loadingView.frame.size.height) / 2, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
        [self.loadingView startAnimating];
    });
}

/**
 * @brief Dismisses the loading view.
 */
- (void)dismissLoadingView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopAnimating];
    });
}


/**
 * @brief Returns an array of objects conforming to SeafSyncSelectorCellDataItemProtocol representing available expiration options.
 *
 * This method creates and returns an array of objects, each implementing the SeafSyncSelectorCellDataItemProtocol.
 * Each object represents an expiration option with a title and a corresponding value (in days).
 *
 * @return An NSMutableArray containing objects conforming to SeafSyncSelectorCellDataItemProtocol representing available expiration options.
 */
- (NSMutableArray<NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *> *)availableExpirations {
    
    //The container
    NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:2];
    
    //numbers component
    NSMutableArray *numbers =[[NSMutableArray alloc] initWithCapacity:365];
    for (NSInteger i = 1; i<=31; i++) {
        [numbers addObject:[[SeafSyncSelectorCellDataItem alloc] initWithTitle:[@(i) stringValue] andValue:@(i)]];
    }
    [components addObject:numbers];
    
    //Scales component
    NSMutableArray<id<SeafSyncSelectorCellDataItemProtocol>> *scales = [[NSMutableArray alloc] initWithCapacity:8];
    [scales addObject:[[SeafSyncSelectorCellDataItem alloc] initWithTitle:@"days" andValue:@1]];
    [scales addObject:[[SeafSyncSelectorCellDataItem alloc] initWithTitle:@"weeks" andValue:@7]];
    [scales addObject:[[SeafSyncSelectorCellDataItem alloc] initWithTitle:@"months" andValue:@30]];
    [scales addObject:[[SeafSyncSelectorCellDataItem alloc] initWithTitle:@"years" andValue:@365]];
    [components addObject:scales];
    
    return components;
}


- (NSMutableArray<id<SeafSyncSelectorCellDataItemProtocol>> *)getSelectedExpirationValues {
    
    //Get components values
    NSMutableArray *allComponentsValues = [self availableExpirations];
    NSMutableArray<id<SeafSyncSelectorCellDataItemProtocol>> *numbers = [allComponentsValues objectAtIndex:0];
    NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *scales = [[[allComponentsValues objectAtIndex:1] reverseObjectEnumerator] allObjects];
    
    
    //What are we doing here?
    //We check  for the first "non modulus" division for bigger to lower
    //Example:
    // If we have 1460 days, we start checking like this:
    // 1460 / 365 => 4 . No modulus, so we return 4 years
    // If we have 90 days, we start checking like this:
    // 90 / 365(years) => 0,24..Modulus, cannot be scale in years
    // 90 / 30 (months) => 3. No modulus. We return 3 months
    //...
    __block NSMutableArray *selectedValues = [[NSMutableArray alloc] init];
    [scales enumerateObjectsUsingBlock:^(id<SeafSyncSelectorCellDataItemProtocol>  _Nonnull scale, NSUInteger scaleIndex, BOOL * _Nonnull stop) {
        if(self.settings.durationOfBackupFilesOnCloudInDays % [scale.value integerValue] == 0){
            NSInteger numberValue = self.settings.durationOfBackupFilesOnCloudInDays / [scale.value integerValue];
            [selectedValues addObject:[numbers objectAtIndex:(numberValue - 1)]];
            [selectedValues addObject:scale];
            * stop = TRUE;
        }
    }];
    
    
    return selectedValues;
    
    
}


/**
 * @brief Returns an object conforming to SeafSyncSelectorCellDataItemProtocol for a given expiration value in days.
 *
 * This method filters the available expiration options and returns the object conforming to SeafSyncSelectorCellDataItemProtocol
 * that corresponds to the provided expiration value in days.
 *
 * @param expirationDays The expiration value in days for which to retrieve the corresponding object.
 * @return An object conforming to SeafSyncSelectorCellDataItemProtocol representing the specified expiration value.
 */
- (id<SeafSyncSelectorCellDataItemProtocol>)getIndexFromExpirationDays:(NSInteger)expirationDays {
    NSArray *availableExpirations = [self availableExpirations];
    
    // Filter the available expiration options based on the provided expiration value in days
    availableExpirations = [availableExpirations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<SeafSyncSelectorCellDataItemProtocol> evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([[evaluatedObject value] integerValue] == expirationDays);
    }]];
    
    // Return the first object in the filtered array (or nil if none found)
    return [availableExpirations firstObject];
}



/**
 * @brief Checks if temporal availability is enabled based on the permanent setting.
 *
 * This method determines if temporal availability is enabled by checking the duration of backup files on the cloud.
 *
 * @return YES if temporal availability is enabled, NO otherwise.
 */

-(BOOL) temporalAvailiabilityEnabledIPermanentSetting{
    return (self.settings.durationOfBackupFilesOnCloudInDays > 0);
}


/**
 * @brief Requests location permission if needed.
 *
 * This method checks the current authorization status and requests location permission if it's not determined.
 * If location access is denied or restricted, a message is logged. If location access is already granted, a message is also logged.
 */
- (void)requestLocationPermissionIfNeeded {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestAlwaysAuthorization];
    }
}


@end

