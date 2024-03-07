//
//  SyncSettingDetailsViewController.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncSettings.h"
#import "SeafSyncronizer.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief The SyncSettingDetailsViewController class for managing synchronization setting details.
 */
@interface SyncSettingDetailsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

/**
 * @brief Constant representing the section index for the error in synchronization settings.
 */
#define ERROR_SECTION                   0

/**
 * @brief Constant representing the section index for the active in synchronization settings.
 */
#define ACTIVE_SECTION                  1

/**
 * @brief Constant representing the section index for the target source in synchronization settings.
 */
#define TARGET_SOURCE_SECTION           2

/**
 * @brief Constant representing the section index for general settings in synchronization settings.
 */
#define SETTINGS_SECTION                3


/**
 * @brief Constant representing the section index for expiration settings in synchronization settings.
 */
#define EXPIRATIONS_SECTION             4

/**
 * @brief Identifier for the default synchronization setting cell.
 */
#define DEFAULT_SYNC_CELL_IDENTIFIER    @"DefaultSyncSettingCell"

/**
 * @brief Initializes a new instance of SyncSettingDetailsViewController.
 *
 * @param settings The SeafSyncSettings object for which details are displayed.
 * @param syncronizer The SeafSyncronizer object managing synchronization settings.
 * @return An initialized instance of SyncSettingDetailsViewController.
 */
-(id) initWithSettings:(SeafSyncSettings *) settings andSyncronizer:(SeafSyncronizer *) syncronizer;

@end

NS_ASSUME_NONNULL_END
