//
//  SeafSyncSettingsView.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import "SeafSyncSettingsViewController.h"
#import "SeafSyncronizer.h"
#import "SeafConnection.h"
#import "SeafSyncEnums.h"
#import "SeafSyncSettingCell.h"
#import "SeafSyncSettings.h"
#import "SeafConnection+UserPlan.h"
#import "SyncSettingDetailsViewController.h"
#import "SeafPlanUser.h"
#import "SeafPlanBasic.h"
#import "SeafAlertChangePlan.h"
#import <Photos/Photos.h>


#define CELL_DISENABLE           1


/**
 * @brief Private interface for SeafSyncSettingsViewController.
 */
@interface SeafSyncSettingsViewController ()

/**
 * @brief Table view for displaying synchronization settings.
 */
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

/**
 * @brief Synchronization manager instance.
 */
@property (nonatomic) SeafSyncronizer *syncronizer;

/**
 * @brief Connection for which the synchronization settings are displayed.
 */
@property (nonatomic) SeafConnection *connection;

/**
 * @brief Array of SeafSyncSettings instances representing synchronization settings.
 */
@property (nonatomic) NSArray<SeafSyncSettings *> *settings;

/**
 * @brief Dictionary representing available synchronization source types.
 */
@property (nonatomic) NSMutableDictionary *availableSourceTypes;

/**
 * @brief UIRefreshControl for enabling pull-to-refresh functionality.
 */
@property (nonatomic) UIRefreshControl *refreshControl;

@end

/**
 * @brief SeafSyncSettingsView implementation.
 */
@implementation SeafSyncSettingsViewController

/**
 * @brief Initializes a new instance of the SeafSyncSettingsViewController.
 *
 * @param connection The SeafConnection for which the settings are displayed.
 * @return An initialized instance of SeafSyncSettingsView.
 */
-(id) initWithConnection:(SeafConnection *) connection{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if(self){
        self.connection = connection;
    }
    return self;
}

/**
 * @brief Called after the controller's view is loaded into memory.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCells];
    [self registerSourceTypes];
    [self registerPullRefresh];
    self.syncronizer = [SeafSyncronizer sharedInstanceFor:self.connection];
    self.settings = [self.syncronizer settings];
    
    // Table settings
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //Controller settings
    self.title = NSLocalizedString(@"Custom backups", @"Seafile");
}

/**
 * @brief Called before the view controller's view is about to be added to a view hierarchy.
 *
 * @param animated If YES, the view is being added to the window using an animation.
 */
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadFreshData];
}

/**
 * @brief Registers pull-to-refresh functionality for the table view.
 */
-(void) registerPullRefresh{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

/**
 * @brief Registers available synchronization source types.
 */
-(void) registerSourceTypes{
    self.availableSourceTypes = [[NSMutableDictionary alloc] initWithCapacity:3];
    [self.availableSourceTypes setObject:@(Folder) forKey:@"Folder"];
    [self.availableSourceTypes setObject:@(Gallery) forKey:@"Gallery"];
    [self.availableSourceTypes setObject:@(Album) forKey:@"Album"];
}

/**
 * @brief Handles the UIRefreshControl's valueChanged event, triggering a data refresh.
 *
 * @param refresh The UIRefreshControl instance.
 */
- (void)handleRefresh:(UIRefreshControl *)refresh {
    [self loadFreshData];
    [self.refreshControl endRefreshing];
}

/**
 * @brief Gets the synchronization source type key for a given index.
 *
 * @param index The index of the synchronization source type.
 * @return The key representing the synchronization source type.
 */
-(NSString *) getKeySourceTypeForIndex:(NSUInteger) index{
   return [[self.availableSourceTypes allKeys] objectAtIndex:index];
}

/**
 * @brief Gets the synchronization source type value for a given index.
 *
 * @param index The index of the synchronization source type.
 * @return The SeafSyncType value representing the synchronization source type.
 */
-(SeafSyncType) getValueSourceTypeForIndex:(NSUInteger) index{
   return (SeafSyncType)[[[self.availableSourceTypes allValues] objectAtIndex:index] integerValue];
}

/**
 * @brief Registers reusable cells for the table view.
 */
-(void) registerCells{
    [self.tableView registerNib:[UINib nibWithNibName:SYNC_CELL_IDENTIFIER bundle:nil] forCellReuseIdentifier:SYNC_CELL_IDENTIFIER];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:DEFAULT_SYNC_CELL_IDENTIFIER];
}

/**
 * @brief Navigates to the details view for a selected synchronization setting.
 *
 * @param indexPath The index path of the selected setting.
 */
-(void) navigateToSettingDetails:(NSIndexPath *)indexPath{
    SyncSettingDetailsViewController *detailsController = [[SyncSettingDetailsViewController alloc] initWithSettings:[self.settings objectAtIndex:indexPath.row] andSyncronizer:self.syncronizer];
    [self.navigationController pushViewController:detailsController animated:TRUE];
}

/**
 * @brief Navigates to the creation view for a new synchronization setting.
 *
 * @param indexPath The index path representing the selected synchronization source type.
 */
-(void) navigateToSettingCreation:(NSIndexPath *)indexPath{
    //New setting
    SeafSyncSettings *newSetting = [[SeafSyncSettings alloc] init];
    [newSetting setActive:TRUE];
    [newSetting setSourceType:[self getValueSourceTypeForIndex:indexPath.row]];
    [newSetting setCreationDate:[NSDate date]];
    [newSetting setConnection:self.connection];
    
    //Request permission for gallery access
    if(newSetting.sourceType == Gallery || newSetting.sourceType == Album){
        [self checkForGalleryPermission];
    }
   
    //Navigate to edit
    SyncSettingDetailsViewController *detailsController = [[SyncSettingDetailsViewController alloc] initWithSettings: newSetting  andSyncronizer:self.syncronizer];
    [self.navigationController pushViewController:detailsController animated:TRUE];
}

/**
 * @brief Loads fresh synchronization settings data and reloads the table view.
 */
-(void) loadFreshData{
    self.settings = [self.syncronizer settings];
    [self.tableView reloadData];
}

//MARK: Table protocol implementation

/**
 * @brief Notifies that a row is selected and performs the appropriate navigation action.
 *
 * @param tableView The table-view object that is notifying.
 * @param indexPath The index path representing the selected row.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == ACTIVE_SETTINGS_SECTION){
        [self navigateToSettingDetails:indexPath];
        return;
    }
    
    [self navigateToSettingCreation:indexPath];
}

/**
 * @brief Returns the number of rows in a given section of a table view.
 *
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return The number of rows in the section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == ACTIVE_SETTINGS_SECTION){
        return [self.settings count];
    }
    // Folder, Gallery, Album
    return 3;
}

/**
 * @brief Returns the number of sections in the table view.
 *
 * @param tableView An object representing the table view requesting this information.
 * @return The number of sections in tableView.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Only 2 sections:
    // - Current settings
    // - Add new setting
    return 2;
}

/**
 * @brief Asks the data source for a cell to insert in a particular location of the table view.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == ACTIVE_SETTINGS_SECTION){
        return [self tableCellForActiveSettingsSection:tableView cellForRowAtIndexPath:indexPath];
    }
    return [self tableCellForCreateSettingsSection:tableView cellForRowAtIndexPath:indexPath];
}

/**
 * @brief Configures and returns a cell for the active settings section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)tableCellForActiveSettingsSection:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SeafSyncSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SYNC_CELL_IDENTIFIER forIndexPath:indexPath];
    if(cell){
        [cell fillData:[self.settings objectAtIndex:indexPath.row]];
    }
    return cell;
}

/**
 * @brief Configures and returns a cell for the create settings section.
 *
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path that locates a row in tableView.
 * @return An object inheriting from UITableViewCell that the table view can use for the specified row.
 */
- (UITableViewCell *)tableCellForCreateSettingsSection:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_SYNC_CELL_IDENTIFIER forIndexPath:indexPath];

    // Title by available options
    NSString *cellText = NSLocalizedString([self getKeySourceTypeForIndex:indexPath.row], @"Seafile");
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.textLabel.text = cellText;

    return cell;
}

/**
 * @brief Asks the data source for the title of the header of the specified section of the table view.
 *
 * @param tableView A table-view object asking for the title.
 * @param section An index number identifying a section in tableView.
 * @return A string to use as the title of the section header.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == ACTIVE_SETTINGS_SECTION){
        return NSLocalizedString(@"Current backups", @"Seafile");
    }
    return NSLocalizedString(@"Create new backup", @"Seafile");
}

/**
 * @brief Asks the data source for the height to use for the header of a particular section.
 *
 * @param tableView A table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return A nonnegative floating-point value that specifies the height (in points) of the header for section.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

-(void) checkForGalleryPermission{
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [self requestForPermission];
    }
}


-(void) requestForPermission{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"Access granted");
        } else {
            // Access denied
            NSLog(@"Access denied");
        }
    }];
}

@end
