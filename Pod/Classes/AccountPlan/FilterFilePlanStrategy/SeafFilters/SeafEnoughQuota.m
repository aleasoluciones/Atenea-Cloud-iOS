//
//  SeafEnoughQuota.m
//  Seafile
//
//  Created by apps meytel on 26/10/23.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "SeafEnoughQuota.h"
#import "SeafFile.h"
#import "SeafConnection.h"
#import "SeafQuotaSupervisor.h"

@interface SeafEnoughQuota ()
@property SeafConnection *connection;
@property SeafQuotaSupervisor *quotaSupervisor;



@end

@implementation SeafEnoughQuota

-(id)initWithConnection:(SeafConnection *)connection {
    self = [super init];
    if(self){
        self.connection = connection;
    }
    
    return self;
}


- (BOOL)meetsCondition:(id<SeafFileProtocol>)itemToEvaluate {
    self.quotaSupervisor =  [SeafQuotaSupervisor sharedInstanceFor:self.connection];
    return [self.quotaSupervisor isEnoughSpaceToUpload: itemToEvaluate.sizeInBytes];
   
}

@end
