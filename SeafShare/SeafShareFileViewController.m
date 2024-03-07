//
//  ShareViewController.m
//  SeafShare
//
//  Created by three on 2018/7/26.
//  Copyright © 2018年 Seafile. All rights reserved.
//

#import "SeafShareFileViewController.h"
#import "UIViewController+Extend.h"
#import "SeafGlobal.h"
#import "SeafStorage.h"
#import "Debug.h"
#import "SeafUploadFile.h"
#import "SeafCell.h"
#import "SeafDateFormatter.h"
#import "FileSizeFormatter.h"
#import "SeafDataTaskManager.h"
#import "SeafInputItemsProvider.h"
#import "SeafFileFilterStrategy.h"
#import "SeafFileFilterBuilder.h"
#import "SeafUploadFileAdapter.h"
#import "SeafCompositeFilter.h"
#import "Support4k.h"
#import "SupportExtension.h"
#import "SeafUploadSize.h"
#import "Support4kPreview.h"
#import "SeafEnoughQuota.h"
#import "SeafTrashChecker.h"
#import "SeafRecoveryFileFolderProvider.h"


@interface SeafShareFileViewController ()<UITableViewDataSource, UITableViewDelegate, SeafUploadDelegate>

@property (nonatomic, strong) NSArray *ufiles;
@property (nonatomic, assign) NSInteger uploadFileCount;
@property (nonatomic, strong) SeafDir *directory;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@end

@implementation SeafShareFileViewController

- (instancetype)initWithDir:(SeafDir *)dir {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainInterface" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"SeafShareFileViewController"];
    if (self) {
        _directory = dir;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IsIpad()) {
        [self setPreferredContentSize:CGSizeMake(480.0f, 540.0f)];
    }
    
    self.navigationItem.title = NSLocalizedString(@"Save to Seafile", @"Seafile");
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *barAppearance = [UINavigationBarAppearance new];
        barAppearance.backgroundColor = [UIColor systemBackgroundColor];
        
        self.navigationController.navigationBar.standardAppearance = barAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = barAppearance;
        
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"Seafile") forState:UIControlStateNormal];
   
    
    [self loadInputs];
    [self setupTableview];
    [self updateDestinationLabel];
}

- (void)loadInputs {
   
    [self showLoadingView];
    __weak typeof(self) weakSelf = self;
    [SeafInputItemsProvider loadInputs:weakSelf.extensionContext complete:^(BOOL result, NSArray *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingView stopAnimating];
            if (result) {
                NSMutableArray *filteredArray = [NSMutableArray array];
                
                for (SeafUploadFile *seafile in array) {
                     SeafUploadFileAdapter *adapterFile = [[SeafUploadFileAdapter alloc] initWithSeafUploadFile:seafile];
                    SeafCompositeFilter *uploadFilter = [SeafFileFilterBuilder getFilterForUpload:self->_directory->connection];
                     id<SeafFileFilterStrategy> filterFailed;
                    if (FALSE == [uploadFilter meetsCondition:adapterFile firstFailedFilter:&filterFailed]) {
                            [weakSelf showAlertForFilteredFiles:filterFailed];
                            Warning(@"File %@ not allowed for upload", seafile.name);
                        } else {
                            [filteredArray addObject:seafile];
                        }
                    }
                
                weakSelf.ufiles = filteredArray;
                weakSelf.uploadFileCount = array.count;
                [weakSelf.tableView reloadData];
                [weakSelf startUpload];
                
          
            } else {
                [weakSelf alertWithTitle:NSLocalizedString(@"Failed to load file", @"Seafile") handler:^{
                    [weakSelf done];
                }];
            }
        });
    }];
}

- (void)showAlertForFilteredFiles:(id<SeafFileFilterStrategy> _Nullable)filterStrategy; {
    NSString *message = nil;
    
    if ([filterStrategy isKindOfClass:[Support4k class]]  || [filterStrategy isKindOfClass:[Support4kPreview class]]) {
          message = NSLocalizedString(@"ACCOUNT_4K_RESTRICTED_MSG_SIMPLE", @"Seafile");
      } else if ([filterStrategy isKindOfClass:[SupportExtension class]]) {
          message = NSLocalizedString(@"ACCOUNT_EXTENSION_RESTRICTED_MSG_SIMPLE", @"Seafile");
      } else if ([filterStrategy isKindOfClass:[SeafUploadSize class]]) {
          message = NSLocalizedString(@"ACCOUNT_UPLOAD_SIZE_LIMIT_MSG_SIMPLE", @"Seafile");
      } else if ([filterStrategy isKindOfClass:[SeafEnoughQuota class]]) {
          message = NSLocalizedString(@"ACCOUNT_QUOTA_EXCEEDED_MSG_SIMPLE", @"Seafile");
      }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)setupTableview {
    self.tableView.estimatedRowHeight = 68;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SeafCell" bundle:nil] forCellReuseIdentifier:@"SeafCell"];
}

- (void)showLoadingView {
    [self.view addSubview:self.loadingView];
    self.loadingView.center = self.view.center;
    self.loadingView.frame = CGRectMake((self.view.frame.size.width-self.loadingView.frame.size.width)/2, (self.view.frame.size.height-self.loadingView.frame.size.height)/2, self.loadingView.frame.size.width, self.loadingView.frame.size.height);
    [self.loadingView startAnimating];
}

- (void)updateDestinationLabel {
    if (_directory) {
        SeafRepo *repo = [_directory->connection getRepo:_directory.repoId];
        NSString *showPath = [NSString stringWithFormat:@"/%@%@", repo.name, _directory.path];
        if ([_directory.path isEqualToString:@"/"]) {
            showPath = [NSString stringWithFormat:@"/%@", repo.name];
        }
        NSString *title = NSLocalizedString(@"Destination", @"Seafile");
        self.destinationLabel.text = [NSString stringWithFormat:@"%@:  %@", title, showPath];
    }
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ufiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SeafCell *cell = [self getCell:@"SeafCell" forTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SeafUploadFile *file = self.ufiles[indexPath.row];
    file.delegate = self;
    cell.textLabel.text = file.name;
    if (@available(iOS 13.0, *)) {
        cell.textLabel.textColor = [UIColor labelColor];
    } else {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.imageView.image = file.previewImage;
    cell.moreButton.hidden = true;
    [self updateCell:cell file:file];
    return cell;
}

- (void)updateCell:(SeafCell *)cell file:(SeafUploadFile *)file {
    if (file.isUploading) {
        cell.progressView.hidden = false;
        [cell.progressView setProgress:file.uProgress];
    } else {
        NSString *sizeStr = [FileSizeFormatter stringFromLongLong:file.filesize];
        if (file.uploaded) {
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@, Uploaded %@", @"Seafile"), sizeStr, [SeafDateFormatter stringFromLongLong:(long long)file.lastFinishTimestamp]];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@, waiting to upload", @"Seafile"), sizeStr];
        }
        cell.cacheStatusView.hidden = true;
        [cell.cacheStatusWidthConstraint setConstant:0.0f];
        [cell layoutIfNeeded];
    }
}

- (SeafCell *)getCell:(NSString *)cellIdentifier forTableView:(UITableView *)tableView {
    SeafCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [cells objectAtIndex:0];
    }
    [cell reset];
    
    return cell;
}

#pragma mark - SeafUploadDelegate
- (void)uploadProgress:(SeafUploadFile *)file progress:(float)progress {
    [self updateFileCell:file result:true progress:progress completed:false];
}

- (void)uploadComplete:(BOOL)success file:(SeafUploadFile *)file oid:(NSString *)oid {
    [self updateFileCell:file result:success progress:1.0f completed:YES];
}

- (void)updateFileCell:(SeafUploadFile *)file result:(BOOL)res progress:(float)progress completed:(BOOL)completed {
    NSIndexPath *indexPath = nil;
    SeafCell *cell = [self getEntryCell:file indexPath:&indexPath];
    if (!cell) return;
    if (!completed && res) {
        cell.progressView.hidden = false;
        cell.detailTextLabel.text = nil;
        [cell.progressView setProgress:progress];
    } else if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (SeafCell *)getEntryCell:(id)entry indexPath:(NSIndexPath **)indexPath {
    NSUInteger index = [self.ufiles indexOfObject:entry];
    if (index == NSNotFound)
        return nil;
    @try {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        if (indexPath) *indexPath = path;
        return (SeafCell *)[self.tableView cellForRowAtIndexPath:path];
    } @catch(NSException *exception) {
        Warning("Something wrong %@", exception);
        return nil;
    }
}

#pragma mark- action
- (IBAction)cancel:(id)sender {
    [SeafDataTaskManager.sharedObject cancelAllUploadTasks:_directory->connection];
    [self done];
}

- (void)startUpload {
    
    [self checkItemsInTrash:self.ufiles onConfirmOverwrite:^{
        for (SeafUploadFile *ufile in self.ufiles) {
            ufile.overwrite = true;
            ufile.udir = self->_directory;
            ufile.delegate = self;
            [ufile setCompletionBlock:^(SeafUploadFile *file, NSString *oid, NSError *error) {
                [self fileUploadComplete:file error:error];
            }];
            [SeafDataTaskManager.sharedObject addUploadTask:ufile];
        }
    }];
 
}

- (void)fileUploadComplete:(SeafUploadFile *)ufile error:(NSError *)error {
    for (SeafUploadFile *file in self.ufiles) {
        if ([ufile.name isEqualToString:file.name]) {
            self.uploadFileCount--;
            break;
        }
    }
    if (self.uploadFileCount == 0) {
        [self done];
    }
}

- (void)done {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.color = [UIColor darkTextColor];
        _loadingView.hidesWhenStopped = YES;
    }
    return _loadingView;
}




//MARK: Trash check

-(void) checkItemsInTrash:(NSArray<SeafUploadFile *> *) files onConfirmOverwrite:(void (^ _Nullable)(void))onConfirm{
    
    SeafTrashChecker *trashChecker = [[SeafTrashChecker alloc] initWithProvider:[[SeafRecoveryFileFolderProvider alloc] initWithConnection:self.directory.getConnection andRepository:self.directory.repoId andPath:self.directory.path]];
    
    NSMutableArray<NSString *> *paths = [[NSMutableArray alloc] initWithCapacity:0];
    
    [files enumerateObjectsUsingBlock:^(SeafUploadFile * _Nonnull uploadFile, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newCompletePath = [self.directory.path stringByAppendingPathComponent:uploadFile.name];
        [paths addObject:newCompletePath];
    }];
    

    [trashChecker existsAnyInTrash:paths callback:^(BOOL exists) {

        if(exists == FALSE){
            onConfirm();
        }
        else{
      
            [self askForOverwriteTrashWithConfirm:(void (^ _Nullable)(void))onConfirm];
        }
           
    }];
    
    
}


- (void) askForOverwriteTrashWithConfirm:(void (^ _Nullable)(void))onConfirm{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"There are items with the same name in the trash.\nDo you want to proceed?", @"Seafile")  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"NO", @"Seafile") style:UIAlertActionStyleDefault  handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"YES", @"Seafile") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onConfirm();
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
