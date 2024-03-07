//
//  SeafSyncSelectorCellDataItem.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 14/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncSelectorCellDataItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncSelectorCellDataItem : NSObject <SeafSyncSelectorCellDataItemProtocol>

- (id) initWithTitle:(NSString *) title andValue:(id) value;

@end




NS_ASSUME_NONNULL_END
