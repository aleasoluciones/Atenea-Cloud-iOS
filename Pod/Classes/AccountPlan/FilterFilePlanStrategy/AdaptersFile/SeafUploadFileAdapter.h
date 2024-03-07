//
//  SeafUploadFileAdaprter.h
//  Seafile
//
//  Created by apps meytel on 4/12/23.
//

#import "SeafUploadFileAdapter.h"
#import "SeafUploadFile.h"
#import "SeafFileProtocol.h"

@interface SeafUploadFileAdapter : NSObject <SeafFileProtocol>

@property (nonatomic, strong) SeafUploadFile *file;
- (instancetype)initWithSeafUploadFile:(SeafUploadFile*)file;

@end

