//
//  CRLFileManager.m
//  CRLCoreLib
//
//  Created by Moshe on 6/25/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "CRLFileManager.h"

@implementation CRLFileManager

/**
 *  @return A singleton instance of the manager.
 */

+ (instancetype)sharedManager
{
    static CRLFileManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CRLFileManager alloc] init];
    });
    
    return manager;
}

/**
 *  @return The path to the application's documents directory.
 */

- (NSString *)pathForApplicationDocumentsDirectory
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSAllDomainsMask] firstObject];
    
    return [url path];
}

/**
 *  @return The path to the application's caches directory.
 */

- (NSString *)pathForApplicationCachesDirectory
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSAllDomainsMask] firstObject];
    
    return [url path];
}

/**
 *  @return The path to the application's library directory.
 */

- (NSString *)pathForApplicationLibraryDirectory
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSAllDomainsMask] firstObject];
    
    return [url path];
}

/**
 *  Writes the given data to the supplied path.
 *  @return YES if the write was successful, else NO.
 */

- (BOOL)writeData:(NSData *)data toPath:(NSString *)path
{
    BOOL saved = NO;
    
    if (data) {
        saved = [data writeToFile:path atomically:YES];
    }
    return saved;
}

@end
