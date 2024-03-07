//
//  SeafSyncDirSelectorViewController.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import "SeafSyncDirSelectorViewController.h"

/**
 * SeafSyncDirSelectorViewController
 * @brief This class represents a view controller for selecting a directory to sync in the Seafile app.
 */
@interface SeafSyncDirSelectorViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *selectItem;

@property (nonatomic, retain) SeafConnection *connection;
@property (nonatomic, retain) SeafDir *directory;
@property (nonatomic, retain) SeafRepo *repository;
@property (nonatomic, retain) NSMutableArray<SeafDir *> *childDirectories;

@property (nonatomic, strong) id<SeafSyncDirSelectorViewControllerDelegate> _delegate;

@property UIActivityIndicatorView *loadingView;
@end

@implementation SeafSyncDirSelectorViewController

/**
 * @brief Initializes the view controller with a connection.
 * @param connection The SeafConnection object.
 * @return An instance of SeafSyncDirSelectorViewController.
 */
- (id)initWithConnection:(SeafConnection *)connection {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.connection = connection;
        self.childDirectories = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

/**
 * @brief Initializes the view controller with a connection and repository.
 * @param connection The SeafConnection object.
 * @param repository The SeafRepo object.
 * @return An instance of SeafSyncDirSelectorViewController.
 */
- (id)initWithConnection:(SeafConnection *)connection andRepo:(SeafRepo *)repository {
    self = [self initWithConnection:connection];
    if (self) {
        self.repository = repository;
    }
    return self;
}

/**
 * @brief Initializes the view controller with a connection, repository, and initial directory.
 * @param connection The SeafConnection object.
 * @param repository The SeafRepo object.
 * @param initialDirectory The initial SeafDir object.
 * @return An instance of SeafSyncDirSelectorViewController.
 */
- (id)initWithConnection:(SeafConnection *)connection andRepo:(SeafRepo *)repository andDir:(SeafDir *)initialDirectory {
    self = [self initWithConnection:connection andRepo:repository];
    if (self) {
        self.directory = initialDirectory;
    }
    return self;
}

/**
 * @brief Sets the delegate for the view controller.
 * @param delegate The delegate object.
 */
- (void)setDelegate:(id<SeafSyncDirSelectorViewControllerDelegate>)delegate {
    self._delegate = delegate;
}

/**
 * @brief Handles the "Confirm" button action to select a directory.
 */
- (void)onConfirmFolder {
    if (self._delegate) {
        [self._delegate onSelectDirecory:self.directory];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 * @brief Called after the controller's view is loaded into memory.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCells];
    [self loadData];
    [self addNavigationButtons];

    // Table settings
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

/**
 * @brief Adds navigation buttons based on the current directory.
 */
- (void)addNavigationButtons {
    if (self.directory) {
        self.title = self.directory.name;
        UIBarButtonItem *confirmButtom = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Here", @"Seafile")
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(onConfirmFolder)];
        self.navigationItem.rightBarButtonItem = confirmButtom;
    } else {
        self.title = NSLocalizedString(@"Select repository", @"Seafile");
    }
}

/**
 * @brief Loads data based on the current context (connection, repository, or directory).
 */
- (void)loadData {
    // If no connection, request from the delegate
    if (self.connection == nil && self._delegate) {
        self.connection = [self._delegate onNeedsConnection];
    }

    [self showLoadingView];

    if (self.directory) {
        [self loadDirectoryData];
        return;
    }

    if (self.repository) {
        [self loadRepositoryData];
        return;
    }

    if (self.connection) {
        [self loadConnectionData];
        return;
    }
}

/**
 * @brief Filters and returns folder items from a list of items.
 * @param items An array of SeafDir or SeafRepo items.
 * @return An array of filtered SeafDir items.
 */
- (NSMutableArray *)filterFolderItems:(NSArray *)items {
    NSPredicate *folderDirectories = [NSPredicate predicateWithBlock:^BOOL(id _Nullable item, NSDictionary<NSString *, id> * _Nullable bindings) {
        return ([item isKindOfClass:[SeafDir class]]) && [((SeafDir *)item) editable] == YES;
    }];

    return [[NSMutableArray alloc] initWithArray:[items filteredArrayUsingPredicate:folderDirectories]];
}

/**
 * @brief Loads data from the connection.
 */
- (void)loadConnectionData {
    [self.connection loadRepos:self];
}

/**
 * @brief Loads data from the repository and filters folder items.
 */
- (void)loadRepositoryData {
    self.childDirectories = [self filterFolderItems:[self.repository items]];
    [self.tableView reloadData];
    [self dismissLoadingView];
}

/**
 * @brief Loads data from the current directory and filters folder items.
 */
- (void)loadDirectoryData {
    [self.directory loadContentSuccess:^(SeafDir *dir) {
        self.childDirectories = [self filterFolderItems:dir.items];
        [self.tableView reloadData];
        [self dismissLoadingView];
    } failure:^(SeafDir *dir, NSError *error) {}];
}

/**
 * @brief Registers cells for the table view.
 */
- (void)registerCells {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

/**
 * @brief Navigates to a selected directory.
 * @param directory The SeafDir object to navigate to.
 */
- (void)navigateToDirectory:(SeafDir *)directory {
    SeafSyncDirSelectorViewController *nestedController = [[SeafSyncDirSelectorViewController alloc] initWithConnection:self.connection andRepo:self.repository andDir:directory];
    [nestedController setDelegate:self._delegate];
    [self.navigationController pushViewController:nestedController animated:YES];
}

/**
 * @brief Handles the selection of a table view cell and navigates to the selected directory.
 * @param tableView The table view.
 * @param indexPath The index path of the selected cell.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self navigateToDirectory:[self.childDirectories objectAtIndex:indexPath.row]];
}

/**
 * @brief Returns the number of rows in the table view section.
 * @param tableView The table view.
 * @param section The section index.
 * @return The number of rows in the section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.childDirectories count];
}

/**
 * @brief Provides a cell to insert at a particular location in the table view.
 * @param tableView The table view.
 * @param indexPath The index path of the cell.
 * @return The UITableViewCell to be displayed.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    SeafDir *directoryToRender = [self.childDirectories objectAtIndex:indexPath.row];

    cell.imageView.image = directoryToRender.icon;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = directoryToRender.name;
    return cell;
}

/**
 * @brief Handles the download completion of an entry.
 * @param entry The SeafBase object.
 * @param updated A boolean indicating whether the download was successful.
 */
- (void)download:(SeafBase *)entry complete:(BOOL)updated {
    NSMutableArray *children = [[NSMutableArray alloc] initWithCapacity:0];
    if ([entry isKindOfClass:[SeafRepos class]]) {
        for (NSMutableArray *repo in [(SeafRepos *)entry repoGroups]) {
            [children addObjectsFromArray:[self filterFolderItems:repo]];
        }
        self.childDirectories = children;
        [self.tableView reloadData];
        [self dismissLoadingView];
    }
}

/**
 * @brief Handles the download progress of an entry.
 * @param entry The SeafBase object.
 * @param progress The download progress as a float value.
 */
- (void)download:(SeafBase *)entry progress:(float)progress {
}

/**
 * @brief Handles a download failure of an entry.
 * @param entry The SeafBase object.
 * @param error The error that occurred during the download.
 */
- (void)download:(SeafBase *)entry failed:(NSError *)error {
}

/**
 * @brief Shows the loading view with an activity indicator.
 */
- (void)showLoadingView {
    if (!self.loadingView) {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingView.color = [UIColor darkTextColor];
        self.loadingView.hidesWhenStopped = YES;
        [self.view addSubview:self.loadingView];
    }

    self.loadingView.center = self.view.center;
    self.loadingView.frame = CGRectMake((self.view.frame.size.width - self.loadingView.frame.size.width) / 2, (self.view.frame.size.height - self.loadingView.frame.size.height) / 2, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
    [self.loadingView startAnimating];
}

/**
 * @brief Dismisses the loading view.
 */
- (void)dismissLoadingView {
    [self.loadingView stopAnimating];
}
@end
