//
//  SeafPermissible.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net)  on 20/11/23.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SeafPermissibleProtocol 

@property (readonly) NSString *permissions;

-(BOOL) canRead;

-(BOOL) canWrite;

@end

NS_ASSUME_NONNULL_END
