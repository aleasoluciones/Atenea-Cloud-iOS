//
//  SeafSyncSelectorCellDataItemProtocol.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 14/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@protocol SeafSyncSelectorCellDataItemProtocol 

@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) id value;

@end


NS_ASSUME_NONNULL_END
