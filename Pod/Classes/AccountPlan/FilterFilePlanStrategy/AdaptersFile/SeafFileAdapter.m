//
//  SeafFileAdapter.m
//  Seafile
//
//  Created by apps meytel on 27/10/23.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "SeafFileAdapter.h"
#import "SeafUploadFile.h"
#import "SeafFile.h"

@implementation SeafFileAdapter

@synthesize fileName;

@synthesize creationDate;

@synthesize identifier;

@synthesize path;

@synthesize sizeInBytes;

@synthesize extension;


- (instancetype)initWithSeafFile:(SeafFile*)file {
   self = [super init];
   if (self) {
       self.file = file;
       
   }
   return self;
}

- (NSString *)fileName {
    return self.file.name;

}

- (long long)sizeInBytes{
    return self.file.filesize;

}

- (NSURL *)path {
    return [NSURL fileURLWithPath:self.file.path];
}



@end
