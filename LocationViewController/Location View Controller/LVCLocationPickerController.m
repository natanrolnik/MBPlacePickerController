//
//  LVCLocationViewController.m
//  LocationViewController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "LVCLocationPickerController.h"
#import "CRLCoreLib.h"
#import "LVCMapView.h"

@import CoreLocation;
@import MapKit;

/**
 *  An URL to the location feed.
 *
 *  TODO: Upload the feed to the server.
 */

static const NSString *kURLLocationList = @"http://mosheberman.com/feeds/locations.json";

/**
 *  An annotation identifier.
 */

static const NSString *kAnnotationIdentifier = @"com.mosheberman.selected-location";

/**
 *
 */

@interface LVCLocationPickerController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

/**
 *  The working location.
 */

@property (nonatomic, strong) CLLocation *location;

/**
 *  An array of location dictionaries.
 */

@property (nonatomic, strong) NSArray *locations;

/**
 *  A table to display a list of locations.
 */

@property (nonatomic, strong) UITableView *tableView;

/**
 *
 */

@property (nonatomic, strong) LVCMapView *map;

@end

@implementation LVCLocationPickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _locations = @[];
        _map = [[LVCMapView alloc] init];
        self.view.backgroundColor = [UIColor colorWithRed:0.25 green:0.53 blue:1.00 alpha:1.00];
    }
    return self;
}

- (void)loadView
{
    /**
     *  Create the view.
     */
    CGRect bounds = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    /**
     *  Configure a map.
     */
    
    CGFloat topGuide = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] topLayoutGuide] length];
    CGFloat navBarHeight = [[[self navigationController] navigationBar] bounds].size.height;
    
    self.map.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGRect mapBounds = self.map.frame;
    mapBounds.origin.y += topGuide + navBarHeight;
    self.map.frame = mapBounds;
    
    /**
     *  Configure a table.
     */
    
    CGRect tableBounds = CGRectMake(0, CGRectGetMaxY(self.map.frame), CGRectGetWidth(bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.map.frame))
    ;
    self.tableView.frame = tableBounds;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    /**
     *
     */
    
    [self.view addSubview:self.map];
    [self.view addSubview:self.tableView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     *  Load up locations.
     */
    
    [self loadLocations];
    [[self tableView] reloadData];
    
    /**
     *  Configure buttons.
     */
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = button;
    
    UIBarButtonItem *autolocateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshLocation)];
    self.navigationItem.leftBarButtonItem = autolocateButton;
    
    /**
     *  Set a background color.
     */
    
    self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    
    /**
     *  Register a table view cell class.
     */
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    /**
     *  Download a updated location list.
     */
    
    NSURL *url = [NSURL URLWithString:(NSString *)kURLLocationList];
    
    [[CRLCoreLib networkManager] downloadDataAtURL:url withCompletion:^(NSData *data) {
        if (data)
        {
            NSError *error = nil;
            NSArray *locations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            
            if (error && ! locations)
            {
                NSLog(@"LocationViewController (CRLCoreLib): Failed to unwrap fresh location list.");
            }
            else if (locations)
            {
                self.locations = locations;
                //  TODO: Ensure existing location is in list.
            }
        }
        else{
            NSLog(@"LocationViewController (CRLCoreLib): Failed to download fresh location list.");
        }
    }];
    
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

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (self.locations.count > indexPath.row)
    {
        NSDictionary *location = self.locations[indexPath.row];
        cell.textLabel.text = location[@"name"]; 
    }
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locations count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.locations.count > indexPath.row)
    {

        NSDictionary *location = self.locations[indexPath.row];
        CLLocationDegrees latitude = [location[@"latitude"] floatValue];
        CLLocationDegrees longitude = [location[@"longitude"] floatValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        self.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.map markCoordinate:coordinate];
    }
}

/**
 *  Loads the locations from the app bundle.
 */

- (void)loadLocations
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSError *error = nil;
    
    if (data) {
        NSArray *locations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
        self.locations = locations;
    }
    else
    {
        NSLog(@"Data load failed.");
    }
}

/**
 *  Centers the map on the user.
 */

- (void)refreshLocation
{

}

#pragma mark - Map Annotations

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:(NSString *)kAnnotationIdentifier];
    
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:(NSString *)kAnnotationIdentifier];
    }
    
    return annotationView;
}

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
//{
//    
//}

@end
