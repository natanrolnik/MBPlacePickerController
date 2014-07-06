//
//  CRLFileManager.h
//  CRLCoreLib
//
//  Created by Moshe on 6/25/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRLFileManager : NSObject

/**
 *  @return A singleton instance of the manager.
 */

+ (instancetype)sharedManager;

/**
 *  @return The path to the application's documents directory.
 */

- (NSString *)pathForApplicationDocumentsDirectory;

/**
 *  @return The path to the application's caches directory.
 */

- (NSString *)pathForApplicationCachesDirectory;

/**
 *  @return The path to the application's library directory.
 */

- (NSString *)pathForApplicationLibraryDirectory;

/**
 *  Writes the given data to the supplied path.
 *  @return YES if the write was successful, else NO.
 */

- (BOOL)writeData:(NSData *)data toPath:(NSString *)path;

@end
