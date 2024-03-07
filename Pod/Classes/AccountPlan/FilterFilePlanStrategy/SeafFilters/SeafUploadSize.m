//
//  SeafUploadSize.m
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "SeafUploadSize.h"
#import "SeafFile.h"
#import "SeafConnection+UserPlan.h"

@interface SeafUploadSize ()
@property SeafPlanUser *planUser;


@end

@implementation SeafUploadSize

-(id)initWithPlan:(SeafPlanUser *)planUser {
    self = [super init];
    if(self){
        self.planUser = planUser;
    }
    
    return self;
}



-(BOOL)meetsCondition:(id<SeafFileProtocol>) itemToEvaluate{
    return (itemToEvaluate.sizeInBytes <= self.planUser.maxUploadSizeFileInBytes);
}

@end
