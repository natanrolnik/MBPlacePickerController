//
//  CRLNetworkManager.h
//  CRLCoreLib
//
//  Created by Moshe on 6/25/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRLNetworkManager : NSObject

/**
 *  @return A singleton instance of the network manager.
 */

+ (instancetype)sharedManager;

/**
 *  Downloads the data at a URL to a given path and then calls a completion block.
 *
 *  @param url A URL to download from.
 *  @param path A local path to save to. Use the CRLFileManager class to get a path to work with.
 *  @param completion A completion block that runs after the data is downloaded and saved.
 *
 */

- (void)downloadDataAtURL:(NSURL *)url toPath:(NSString *)path withCompletion:(void(^)(BOOL success))completion;

/**
 *  Downloads the data at a URL and passes it to a completion block.
 *
 *  @param url A URL to download from.
 *  @param completion A completion block that runs after the data is downloaded and saved.
 *
 */

- (void)downloadDataAtURL:(NSURL *)url withCompletion:(void(^)(NSData *data))completion;

@end
