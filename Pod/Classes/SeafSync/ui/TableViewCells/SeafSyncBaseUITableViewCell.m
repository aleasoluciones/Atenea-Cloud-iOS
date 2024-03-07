//
//  SeafSyncBaseUITableViewCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 16/11/23.
//

#import "SeafSyncBaseUITableViewCell.h"

@implementation SeafSyncBaseUITableViewCell

-(void) setActiveState:(BOOL) active{
    
    if(active){
        self.contentView.alpha = 1;
        self.userInteractionEnabled = TRUE;
        return;
    }
    
    self.contentView.alpha = 0.1;
    self.userInteractionEnabled = FALSE;
}

@end
