//
//  SeafFileProtocol.h
//  Pods
//
//  Created by apps meytel on 23/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol SeafFileProtocol 
    
@property (nonatomic, strong)  id identifier;

@property (nonatomic, strong)  NSDate *creationDate;

@property (nonatomic) long long sizeInBytes;
    
@property (nonatomic, strong)  NSURL *path;

@property (nonatomic, strong)  NSString *extension;

@property (nonatomic, strong)  NSString *fileName;

@end

NS_ASSUME_NONNULL_END
