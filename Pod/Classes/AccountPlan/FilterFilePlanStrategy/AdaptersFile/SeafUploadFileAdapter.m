//
//  SeafUploadFileAdapter.m
//  Seafile
//
//  Created by apps meytel on 4/12/23.
//
#import <Foundation/Foundation.h>
#import "SeafUploadFileAdapter.h"
#import "SeafUploadFile.h"

@implementation SeafUploadFileAdapter

@synthesize fileName;

@synthesize creationDate;

@synthesize identifier;

@synthesize path;

@synthesize sizeInBytes;

@synthesize extension;


- (instancetype)initWithSeafUploadFile:(SeafUploadFile*)file {
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
    return [NSURL fileURLWithPath:self.file.lpath];
}



@end
