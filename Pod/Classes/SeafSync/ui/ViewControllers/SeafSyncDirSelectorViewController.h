//
//  SeafSyncDirSelectorViewController.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafConnection.h"
#import "SeafDir.h"
#import "SeafPreView.h"
#import "SeafRepos.h"
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SeafSyncDirSelectorViewControllerDelegate

- (void) onSelectDirecory:(SeafDir *) directory;

@optional
- (SeafConnection *) onNeedsConnection;

@end

@interface SeafSyncDirSelectorViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,SeafDentryDelegate>

-(id) initWithConnection:(SeafConnection *) connection;

-(id) initWithConnection:(SeafConnection *) connection andRepo:(SeafRepo *) repository;

-(id) initWithConnection:(SeafConnection *) connection  andRepo:(SeafRepo *) repository andDir:(SeafDir *) initialDirectory;

-(void) setDelegate:(id<SeafSyncDirSelectorViewControllerDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
