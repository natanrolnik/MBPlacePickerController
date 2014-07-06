//
//  CRLNetworkManager.m
//  CRLCoreLib
//
//  Created by Moshe on 6/25/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "CRLNetworkManager.h"

@implementation CRLNetworkManager

/**
 *  @return A singleton instance of the network manager.
 */

+ (instancetype)sharedManager
{
    static CRLNetworkManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CRLNetworkManager alloc] init];
    });
    
    return manager;
}

/**
 *  Downloads the data at a URL to a given path and then calls a completion block.
 *
 *  @param url A URL to download from.
 *  @param path A local path to save to. Use the CRLFileManager class to get a path to work with.
 *  @param completion A completion block that runs after the data is downloaded and saved.
 *
 */

- (void)downloadDataAtURL:(NSURL *)url toPath:(NSString *)path withCompletion:(void(^)(BOOL success))completion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        BOOL saved = NO;
        
        if (data) {
            saved = [data writeToFile:path atomically:YES];
        }
        
        if (completion) {
            completion(saved);
        }
    }];
}

/**
 *  Downloads the data at a URL and passes it to a completion block.
 *
 *  @param url A URL to download from.
 *  @param completion A completion block that runs after the data is downloaded and saved.
 *
 */

- (void)downloadDataAtURL:(NSURL *)url withCompletion:(void(^)(NSData *data))completion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (completion) {
            completion(data);
        }
    }];
}

@end
