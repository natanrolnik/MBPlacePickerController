//
//  MBPlacePickerDelegate.h
//  MBPlacePickerController
//
//  Created by Moshe on 7/5/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBPlacePickerController.h"

@import CoreLocation;

@class MBPlacePickerController;

@protocol MBPlacePickerDelegate <NSObject>

/**
 *  Called when the user selects a location or when the location manager updates.
 */

- (void)placePickerController:(MBPlacePickerController *)placePicker didChangeToPlace:(CLLocation *)place;

@end
