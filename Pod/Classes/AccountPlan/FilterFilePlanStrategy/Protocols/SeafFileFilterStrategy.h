//
//  SeafFileFilterStrategy.h
//  Pods
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafFileProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SeafFileFilterStrategy <NSObject>

-(BOOL) meetsCondition:(id<SeafFileProtocol>) itemToEvaluate;

@end

NS_ASSUME_NONNULL_END
