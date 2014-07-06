//
//  LVCLocationViewController.h
//  LocationViewController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMapView.h"

@interface MBPlacePickerController : UIViewController

/**
 *  A flag to determine if the locations should be sorted by continent.
 *  Default is YES.
 */

@property (nonatomic, assign) BOOL sortByContinent;

/**
 *  A flag to determine if the user's location should be displayed.
 *  Default is NO.
 */

@property (nonatomic, assign) BOOL showUserLocation;
           
/**
 *  Asks the rootViewController of the keyWindow to display the location view controller.
 */

- (void)display;

/**
 *  Asks the rootViewController of the keyWindow to dismiss whatever it's showing.
 */

- (void)dismiss;

/**
 *  A view that renders the map.
 */

@property (nonatomic, strong, readonly) MBMapView *map;

@end
