//
//  SupportExtension.m
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "SupportExtension.h"
#import "SeafFile.h"
#import "SeafConnection+UserPlan.h"

@interface SupportExtension ()
@property SeafPlanUser *planUser;




@end

@implementation SupportExtension

-(id)initWithPlan:(SeafPlanUser *)planUser
 {
    self = [super init];
    if(self){
        self.planUser = planUser;
    }
    
    return self;
}



- (NSString *)fileExtensionFromURL:(NSString *)urlString {
     if (![urlString isKindOfClass:[NSString class]]) {
         return nil;
     }
     NSString *encodedURLString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
     NSURL *url = [NSURL URLWithString:encodedURLString];
     NSString *pathExtension = url.pathExtension;
     return [pathExtension lowercaseString];
}


- (BOOL)extension:(NSString *)string isInArray:(NSArray<NSString *> *)array {
    return [array containsObject:string];
}



-(BOOL)meetsCondition:(id<SeafFileProtocol>) itemToEvaluate{
    NSString *extensionFile = [self fileExtensionFromURL:itemToEvaluate.fileName];

    //esta dentro del array de dontAllowExtension entonces devuelvo que no cumple este filtro
    if ([self extension:extensionFile isInArray:self.planUser.dontAllowedExtensions]){
        return NO;
    }else{
        return YES;
    }
}

@end
