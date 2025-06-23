//
//  SeafRecoverySelectorViewController.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net)  on 30/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafRecoveryItem.h"
#import "SeafConnection.h"
#import "SeafRecoveryItemsProvider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SeafRecoverySelectorViewControllerDelegate
@optional
- (void) onRecovery;
@end


@interface SeafRecoverySelectorViewController : UITableViewController

-(id) initWithConnection:(SeafConnection *) connection andProvider:(id<SeafRecoveryItemsProvider>) provider editable:(BOOL) editable clearable:(BOOL) clearable;

@property id<SeafRecoverySelectorViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
