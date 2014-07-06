//
//  CRLCoreLib.h
//  CRLCoreLib
//
//  Created by Moshe on 6/25/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CRLDataManager.h"
#import "CRLNetworkManager.h"
#import "CRLFileManager.h"

@interface CRLCoreLib : NSObject

/**
 *  @return The version of the library.
 */

+ (NSString *)version;

/**
 *  @return The singleton instance of the data manager.
 */

+ (CRLDataManager *)dataManager;

/**
 *  @return The singleton instance of the network manager.
 */

+ (CRLNetworkManager *)networkManager;

/**
 *  @return The singleton instance of the file manager.
 */

+ (CRLFileManager *)fileManager;

@end
