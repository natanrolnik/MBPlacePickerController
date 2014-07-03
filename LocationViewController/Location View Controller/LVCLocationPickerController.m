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
 *  A dictionary of dictionaries, sorted by continent.
 */

@property (nonatomic, strong) NSDictionary *locationsByContinent;
/**
 *  A table to display a list of locations.
 */

@property (nonatomic, strong) UITableView *tableView;

/**
 *  A view that renders the map.
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
        _sortByContinent = YES;
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
    
    self.map.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;;
    CGRect mapFrame = self.map.frame;
    mapFrame.origin.y = [self.topLayoutGuide length];
    self.map.frame = mapFrame;
    [self.view addSubview:self.map];
    
    /**
     *  Configure a table.
     */
    
    CGRect tableBounds = CGRectMake(0, CGRectGetMaxY(self.map.frame), CGRectGetWidth(bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.map.frame));
    ;
    self.tableView.frame = tableBounds;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
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
    
    /**
     *  Configure buttons.
     */
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = button;
    
//    UIBarButtonItem *autolocateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshLocation)];
//    self.navigationItem.leftBarButtonItem = autolocateButton;
    
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
    
    /**
     *
     */
    if (self.sortByContinent == YES)
    {
        //  Gets the name of the continent.
        NSString *continent = [self _sortedContinentNames][indexPath.section];
        
        //  Gets all the locations in the continent
        NSArray *locationsForContinent = [self locationsByContinent][continent];
        
        //  Gets a specific location from the continent.
        NSInteger row = indexPath.row;
        if (row < locationsForContinent.count) {
            NSDictionary *location = locationsForContinent[row];
            cell.textLabel.text = location[@"name"];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", @(row)];
        }
    }
    
    /** 
     *  ...else just try to find an unsorted location.
     */
    else
    {
        
         if (self.locations.count > indexPath.row)
         {
             NSDictionary *location = self.locations[indexPath.row];
             cell.textLabel.text = location[@"name"];
         }
    }
    return cell;
}

/**
 *  Return enough rows for the continent, or for all unsorted locations.
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat count = 0;
    
    if (self.sortByContinent == YES)
    {
        NSString *continentKeyForSection = [self _sortedContinentNames][section];
        count = [self.locationsByContinent[continentKeyForSection] count];
    }
    else{
        count = [self.locations count];
    }
    
    return count;
}

/**
 *  Return enough sections for each continent.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sortByContinent == YES)
    {
        return self.locationsByContinent.allKeys.count;
    }
    return 1;
}

/**
 *  Handle cell selection.
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.locations.count > indexPath.row)
    {

        NSDictionary *location = self.locations[indexPath.row];
        
        if (self.sortByContinent)
        {
            //  Gets the name of the continent.
            NSString *continent = [self _sortedContinentNames][indexPath.section];
            
            //  Gets all the locations in the continent
            NSArray *locationsForContinent = [self locationsByContinent][continent];
            
            //  Gets a specific location from the continent.
            NSInteger row = indexPath.row;
            if (row < locationsForContinent.count) {
                location = locationsForContinent[row];
            }
        }
        
        CLLocationDegrees latitude = [location[@"latitude"] floatValue];
        CLLocationDegrees longitude = [location[@"longitude"] floatValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        self.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        /**
         *  Update the map.
         */
        
        [self.map markCoordinate:coordinate];
    }
}

/**
 *  Return the continent name for each section.
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    if (self.sortByContinent == YES)
    {
        title = [self _sortedContinentNames][section];
    }
    
    return title;
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


- (void)setLocations:(NSArray *)locations
{
    if (locations)
    {
        _locations = locations;
        [self processLocations];    //  Sort by continent.
    }
}
/**
 *  Converts an array of locations to a dictionary of locations sorted by continent.
 */

- (void)processLocations
{
    NSMutableDictionary *continents = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *location in self.locations)
    {
        NSString *continent = location[@"continent"];
        
        /**
         *  If there's no continent, skip the location.
         */
        
        if (!continent)
        {
            continue;
        }
        
        /**
         *  Ensure we have an array for the location.
         */
        
        if (!continents[continent]) {
            continents[continent] = [[NSMutableArray alloc] init];
        }
        
        /**
         *  Add the location.
         */
        
        [continents[continent] addObject:location];
    }
    
    self.locationsByContinent = continents;
}

/**
 *  @return The continents, sorted by name.
 */

- (NSArray *)_sortedContinentNames
{
    return [self.locationsByContinent.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

/**
 *
 */

- (void)setSortByContinent:(BOOL)sortByContinent
{
    _sortByContinent = sortByContinent;
    
    [self loadLocations];
    [[self tableView] reloadData];
}
@end
