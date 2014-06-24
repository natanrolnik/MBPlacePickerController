//
//  LVCLocationViewController.m
//  LocationViewController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "LVCLocationPickerController.h"

@import CoreLocation;
@import MapKit;

@interface LVCLocationPickerController ()

/**
 *
 */

@property (nonatomic, strong) CLLocation *location;

/**
 *  An array of location dictionaries.
 *
 *  
 *
 */

@property (nonatomic, strong) NSArray *locations;

@end

@implementation LVCLocationPickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    CGRect bounds = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    
    self.view = [[UIView alloc] initWithFrame:bounds];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = button;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 *  Asks the rootViewController of the keyWindow to display self.
 */

- (void)display
{
    if ([self.parentViewController isKindOfClass:[UINavigationController class]])
    {
     [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.parentViewController animated:YES completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:nil];
    }
}

/**
 *  Asks the parent VC to dismiss self.
 */

- (void)dismiss
{
    if ([[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController isEqual:self])
    {
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.presentingViewController != nil)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
