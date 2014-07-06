//
//  CRLCoreLib.m
//  CRLCoreLib
//
//  Created by Moshe on 6/25/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "CRLCoreLib.h"

static NSString *kLibraryVersion = @"1.0.0";

@implementation CRLCoreLib

/**
 *  @return The version of the library.
 */

+ (NSString *)version
{
    return kLibraryVersion;
}

/**
 *  @return The singleton instance of the data manager.
 */

+ (CRLDataManager *)dataManager
{
    return [CRLDataManager sharedManager];
}

/**
 *  @return The singleton instance of the network manager.
 */

+ (CRLNetworkManager *)networkManager
{
    return [CRLNetworkManager sharedManager];
}

/**
 *  @return The singleton instance of the file manager.
 */

+ (CRLFileManager *)fileManager
{
    return [CRLFileManager sharedManager];
}


@end
