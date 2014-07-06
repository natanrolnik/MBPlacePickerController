//
//  CRLDataManager.m
//  CRLCoreLib
//
//  Created by Moshe on 6/25/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "CRLDataManager.h"

@implementation CRLDataManager

/**
 *  @return A singleton instance of the data managr.
 */

+ (instancetype)sharedManager
{
    static CRLDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CRLDataManager alloc] init];
    });
    
    return manager;
}

@end
