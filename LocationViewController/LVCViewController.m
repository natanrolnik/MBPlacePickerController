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

@end

@implementation LVCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showLocationPickerController:(id)sender {
    LVCLocationPickerController *locationPicker = [[LVCLocationPickerController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationPicker];
    
    [locationPicker display];
}

@end
