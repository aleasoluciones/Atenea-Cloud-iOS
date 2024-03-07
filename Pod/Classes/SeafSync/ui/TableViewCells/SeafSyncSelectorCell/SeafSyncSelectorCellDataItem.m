//
//  SeafSyncSelectorCellDataItem.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 14/11/23.
//

#import "SeafSyncSelectorCellDataItem.h"

@implementation SeafSyncSelectorCellDataItem
@synthesize title;
@synthesize value;

- (id) initWithTitle:(NSString *) title andValue:(id) value;{
    self = [super init];
    if(self){
        self.title =title;
        self.value = value;
    }
    
    return self;
}

@end
