//
//  LVCLocationViewController.h
//  LocationViewController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMapView.h"
#import "MBPlacePickerDelegate.h"

@interface MBPlacePickerController : UIViewController

/**
 *  A flag to determine if the locations should be sorted by continent.
 *  Default is YES.
 */

@property (nonatomic, assign) BOOL sortByContinent;

/**
 *  A URL to use to update the location list.
 *  The default points to the GitHub repo.
 */

@property (nonatomic, strong) NSString *serverURL;

/**
 *  A view that renders the map.
 */

@property (nonatomic, strong, readonly) MBMapView *map;

/**
 *  A delegate to handle location changes.
 */

@property (nonatomic, assign) id<MBPlacePickerDelegate> delegate;

#pragma mark - Presenting and Dismissing the Picker

/** ---
 *  @name Presenting and Dismissing the Picker
 *  ---
 */

/**
 *  Asks the rootViewController of the keyWindow to display the location view controller.
 */

- (void)display;

/**
 *  Asks the rootViewController of the keyWindow to dismiss whatever it's showing.
 */

- (void)dismiss;

/** ---
 *  @name Update the location database
 *  ---
 */
/**
 *  Updates the location data from the server, then reloads the tableview.
 */

- (void)refreshLocationsFromServer;

@end
