//
//  SeafFileAdapter.h
//  Seafile
//
//  Created by apps meytel on 27/10/23.
//
#import "SeafFileProtocol.h"
#import "SeafFile.h"

@interface SeafFileAdapter : NSObject <SeafFileProtocol>

@property (nonatomic, strong) SeafFile *file;
- (instancetype)initWithSeafFile:(SeafFile*)file;

@end

