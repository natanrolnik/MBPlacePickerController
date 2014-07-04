//
//  LVCViewController.m
//  LocationViewController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "LVCViewController.h"
#import "LVCLocationPickerController.h"

@interface LVCViewController ()

/**
 *  The location picker.
 */

@property (nonatomic, strong) LVCLocationPickerController *locationPickerController;
/**
 *  A switch to toggle the continent sort.
 */

@property (weak, nonatomic) IBOutlet UISwitch *sortByContinentSwitch;

@end

@implementation LVCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
        self.locationPickerController = [[LVCLocationPickerController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showLocationPickerController:(id)sender {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.locationPickerController];
    
    [self.locationPickerController display];
}

/**
 *
 */

- (IBAction)toggleSortByContinent:(id)sender
{
    [self.locationPickerController setSortByContinent:self.sortByContinentSwitch.on];
}

@end
