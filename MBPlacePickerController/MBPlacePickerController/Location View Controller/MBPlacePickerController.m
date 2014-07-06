//
//  LVCLocationViewController.m
//  LocationViewController
//
//  Created by Moshe on 6/23/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "MBPlacePickerController.h"
#import "MBMapView.h"

#import "CRLCoreLib.h"
#import "MBLocationManager.h"

@import CoreLocation;
@import MapKit;

/**
 *
 */

static NSIndexPath *previousIndexPath = nil;

/**
 *
 */

@interface MBPlacePickerController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

/**
 *  The working location.
 */

@property (nonatomic, strong) CLLocation *location;

/**
 *  An array of location dictionaries.
 */

@property (nonatomic, strong) NSArray *unsortedLocationList;

/**
 *  A dictionary of dictionaries, sorted by continent.
 */

@property (nonatomic, strong) NSDictionary *locationsByContinent;

/**
 *  A table to display a list of locations.
 */

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MBPlacePickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _unsortedLocationList = @[];
        _locationsByContinent = @{};
        _map = [[MBMapView alloc] init];
        _sortByContinent = YES;
        _serverURL = @"https://raw.githubusercontent.com/MosheBerman/LocationViewController/master/server-locations.json";
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
    mapFrame.origin.x = CGRectGetMidX(self.view.bounds) - CGRectGetMidX(mapFrame);
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

#pragma mark - View Lifecycle

/** ---
 *  @name View Lifecycle
 *  ---
 */

/**
 *  Calls the vanilla viewDidLoad then does a ton of loading itself...
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     *  Load up locations.
     */
    
    [self loadLocationsFromDisk];
    
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /**
     *  TODO: Re-size map if necessary.
     */
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    previousIndexPath = nil;
    [self refreshLocationsFromServer];
    
    [self.map markCoordinate:self.location.coordinate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Presenting and Dismissing the Picker

/** ---
 *  @name Presenting and Dismissing the Picker
 *  ---
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

/** ---
 *  @name UITableView Data Source
 *  ---
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *location =  nil;
    
    /**
     *  If the locations are sorted by continent, pull out the appropriate one.
     */
    
    if (self.sortByContinent == YES)
    {
        //  Gets the name of the continent.
        NSString *continent = [self _sortedContinentNames][indexPath.section];
        
        //  Gets all the locations in the continent
        NSArray *locationsForContinent = [self locationsByContinent][continent];
        
        //  Gets a specific location from the continent.
        NSInteger row = indexPath.row;
        
        if (row < locationsForContinent.count)
        {
            location = locationsForContinent[row];
        }
    }
    
    /**
     *  ...else just try to find an unsorted location.
     */
    else
    {
        
        if (self.unsortedLocationList.count > indexPath.row)
        {
            location = self.unsortedLocationList[indexPath.row];
        }
    }
    
    cell.textLabel.text = location[@"name"];
    
    /**
     *  Compare the display cell's backing location to the currently selected one.
     */
    
    CGFloat lat = [location[@"latitude"] floatValue];
    CGFloat lon = [location [@"longitude"] floatValue];
    
    CGFloat storedLat = self.location.coordinate.latitude;
    CGFloat storedLon = self.location.coordinate.longitude;
    
    if (lat == storedLat && lon == storedLon)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
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
        count = [self.unsortedLocationList count];
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
 *  @param tableView The table view.
 *  @param section A section.
 *
 *  @return The string "Unsorted" if alphabetical, otherwise the name of a continent.
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Unsorted";
    
    if (self.sortByContinent == YES)
    {
        title = [self _sortedContinentNames][section];
    }
    
    return title;
}

#pragma mark - UITableViewDelegate

/** ---
 *  @name UITableViewDelegate
 *  ---
 */

/**
 *  Handle cell selection.
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSDictionary *location = self.unsortedLocationList[indexPath.row];
    
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
    
    /**
     *  Extract the location from the tapped location.
     */
    
    CLLocationDegrees latitude = [location[@"latitude"] floatValue];
    CLLocationDegrees longitude = [location[@"longitude"] floatValue];
    
    /**
     *  Store it as a CLLocation in the location picker.
     */
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    self.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    /**
     *  Update the map.
     */
    
    [self.map markCoordinate:coordinate];
    
    /**
     *
     */
    
    if (previousIndexPath && ! [indexPath isEqual:previousIndexPath])
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath, previousIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    previousIndexPath = indexPath;
    
    
}

#pragma mark - Location List

/**
 *  Updates the location data from the server, then reloads the tableview.
 */

- (void)refreshLocationsFromServer
{
    /**
     *  Download a updated location list.
     */
    
    NSURL *url = [NSURL URLWithString:self.serverURL];
    
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
                if (!locations.count) {
                    NSLog(@"LocationViewController (CRLCoreLib): Recieved an empty list of locations.");
                }
                else
                {
                    NSString *path = [[[CRLCoreLib fileManager] pathForApplicationLibraryDirectory] stringByAppendingString:@"/locations.json"];;
                    [[CRLCoreLib fileManager] writeData:data toPath:path];
                    
                    [self setUnsortedLocationList:locations];
                    //  TODO: Ensure existing location is in list, if not, add it.
                    [[self tableView] reloadData];
                }
            }
        }
        else{
            NSLog(@"LocationViewController (CRLCoreLib): Failed to download fresh location list.");
        }
    }];
}

/**
 *  Loads the locations from the app bundle.
 */

- (void)loadLocationsFromDisk
{
    
    NSString *applicationString = [[CRLCoreLib fileManager] pathForApplicationLibraryDirectory];
    NSString *locationsPath = [applicationString stringByAppendingString:@"/locations.json"];
    NSData *localData = [[NSData alloc] initWithContentsOfFile:locationsPath];
    
    NSError *error = nil;
    
    if (!localData)
    {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"json"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        
        
        if (data) {
            NSArray *locations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            self.unsortedLocationList = locations;
        }
        else
        {
            NSLog(@"Data load failed.");
        }
    }
    else
    {
        NSArray *locations = [NSJSONSerialization JSONObjectWithData:localData options:NSJSONReadingMutableContainers error:&error];
        
        self.unsortedLocationList = locations;
    }
}

/**
 *  Converts an array of locations to a dictionary of locations sorted by continent.
 */

- (void)_sortArrayOfLocationsByContinent
{
    NSMutableDictionary *continents = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *location in self.unsortedLocationList)
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

#pragma mark - Accessing Sorted Locations

/** ---
 *  @name Accessing Sorted Locations
 *  ---
 */
/**
 *  @return The continents, sorted by name.
 */

- (NSArray *)_sortedContinentNames
{
    return [self.locationsByContinent.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark - Custom Setters

/** ---
 *  @name Custom Setters
 *  ---
 */

/**
 *  Sets the array of locations, then creates a sorted copy of the same locations, by continent.
 *
 *  @param locations An array of dictionaries describing locations.
 */

- (void)setUnsortedLocationList:(NSArray *)locations
{
    if (locations)
    {
        _unsortedLocationList = locations;
        [self _sortArrayOfLocationsByContinent];    //  Sort by continent.
    }
}

/**
 *  @param sortByContinent A parameter to toggle the sort order of the locations.
 */

- (void)setSortByContinent:(BOOL)sortByContinent
{
    _sortByContinent = sortByContinent;
    
    if (sortByContinent)
    {
        [self _sortArrayOfLocationsByContinent];
    }
    
    [[self tableView] reloadData];
}

@end
