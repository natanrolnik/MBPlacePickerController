//
//  LVCViewController.m
//  LocationViewController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "MBViewController.h"
#import "MBPlacePickerController.h"

@interface MBViewController () <MBPlacePickerDelegate>

/**
 *  The location picker.
 */

@property (nonatomic, strong) MBPlacePickerController *locationPickerController;
/**
 *  A switch to toggle the continent sort.
 */

@property (weak, nonatomic) IBOutlet UISwitch *sortByContinentSwitch;

/**
 *  A switch to toggle display of user's location.
 */

@property (weak, nonatomic) IBOutlet UISwitch *showUserLocationSwitch;

/**
 *  A label to show the latest latitude.
 */

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;

/**
 *  A label to show the latest longitude.
 */

@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@end

@implementation MBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /**
     *  Create the location picker now.
     *
     *  If we create it too early, the map doesn't initialize correctly.
     *  TODO: This is a bug, and should be fixed.
     */
    
    self.locationPickerController = [[MBPlacePickerController alloc] init];
    self.locationPickerController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    /**
     *  Add a border to the buttons and views with the arbitrarily chosen tag 55.
     */
    
    for (id view in self.view.subviews)
    {
        if ([view isKindOfClass:[UIButton class]] || [view tag] == 55)
        {
            UIButton *b = view;
            
            b.layer.borderColor = b.tintColor.CGColor;
            b.layer.borderWidth = 1.0;
            b.layer.cornerRadius = 5.0;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showLocationPickerController:(id)sender {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.locationPickerController];
    
    if (navigationController) {
        [self.locationPickerController display];
    }
}

/**
 *  Toggles sorting by continent.
 */

- (IBAction)toggleSortByContinent:(id)sender
{
    [self.locationPickerController setSortByContinent:self.sortByContinentSwitch.on];
}

/**
 *  Toggles the display of the user's location.
 */

- (IBAction)toggleShowUserLocation:(id)sender
{
    [self.locationPickerController.map setShowUserLocation:self.showUserLocationSwitch.on];
}

/**
 *  Changes the marker size.
 */

- (IBAction)markerSizeChanged:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *s = sender;
        [self.locationPickerController.map setMarkerDiameter:s.value];
    }

}

#pragma mark - MBPlacePickerController

- (void)placePickerController:(MBPlacePickerController *)placePicker didChangeToPlace:(CLLocation *)place
{
    CGFloat lat = place.coordinate.latitude;
    CGFloat lon = place.coordinate.longitude;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"Latitude: %f", lat];
    self.longitudeLabel.text = [NSString stringWithFormat:@"Longitude: %f", lon];
}

@end
