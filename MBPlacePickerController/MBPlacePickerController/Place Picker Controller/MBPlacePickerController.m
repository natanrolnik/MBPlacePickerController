//
//  MBPlacePickerController.m
//  MBPlacePickerController
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
 *  A key used to persist the last location.
 */

static NSString *kLocationPersistenceKey = @"com.mosheberman.location-persist-key";

/**
 *
 */

@interface MBPlacePickerController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

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

/**
 *  A flag to determine if we're using the user's location or not.
 */

@property (nonatomic, assign) BOOL automaticUpdates;

/**
 *  A navigation controller to present inside of.
 */
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation MBPlacePickerController

/**
 *  @return A singleton instance of MBPlacePickerController.
 */

+ (instancetype)sharedPicker
{
    static MBPlacePickerController *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MBPlacePickerController alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _unsortedLocationList = @[];
        _locationsByContinent = @{};
        _map = [[MBMapView alloc] init];
        _sortByContinent = YES;
        _serverURL = @"";
        _automaticUpdates = NO;
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self];

        /**
         *  Load the cached location.
         */
        
        NSDictionary *previousLocationData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLocationPersistenceKey];
        
        CGFloat lat = [previousLocationData[@"latitude"] floatValue];
        CGFloat lon = [previousLocationData[@"longitude"] floatValue];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        
        _location = location;
        
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
     *  A "Done" button.
     */
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = button;
    
    /**
     *   A button for automatic location updates.
     */
    
    UIBarButtonItem *autolocateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Automatic", @"A title for automatic location updates") style:UIBarButtonItemStyleBordered target:self action:@selector(enableAutomaticUpdates)];
    
    self.navigationItem.leftBarButtonItem = autolocateButton;
    
    /**
     *  Set a title.
     */
    
    self.title = NSLocalizedString(@"Place Picker", @"A title for the place picker.");
    
    /**
     *  Set a background color.
     */
    
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.01 blue:0.20 alpha:1.00];
    
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
    
    if(!self.automaticUpdates)
    {
        [self.map markCoordinate:self.location.coordinate];
    }
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
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
}

/**
 *  Asks the parent VC to dismiss self.
 */

- (void)dismiss
{
 [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
 }];
}

#pragma mark - Automatic Location Updates

/** ---
 *  @name Automatic Location Updates
 *  ---
 */

/**
 *  This method automatically updates the
 *  location and calls the delegate when
 *  there are changes to report.
 */

- (void)enableAutomaticUpdates
{
    /**
     *  Don't enable twice in a row.
     */
    
    if (self.automaticUpdates)
    {
        return;
    }
    
    /**
     *  Set the flag.
     */
    
    self.automaticUpdates = YES;
    
    /**
     *  Hide the red map marker.
     */
    [self.map hideMarker];
    
    /**
     *  Trigger automatic location updates.
     */
    
    [[MBLocationManager sharedManager] updateLocationWithCompletionHandler:^(NSArray *locations, CLHeading *heading, CLAuthorizationStatus authorizationStatus) {
        
        /**
         *  On each update, pull the location.
         */
        
        CLLocation *lastLocation = [[MBLocationManager sharedManager] location];
        
        /**
         *  If there's a location...
         */
        if (lastLocation)
        {
            /**
             *  ...assign the location...
             */
            self.location = lastLocation;
            
            /**
             *  Reload the table so we don't have an extra checkmark.
             */
            
            if (previousIndexPath != nil)
            {
                [[self tableView] reloadRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            /**
             *  ...display it...
             */
            [self.map setShowUserLocation:YES];
            
            /**
             *  ...and attempt to call the delegate.
             */
            if ([self.delegate respondsToSelector:@selector(placePickerController:didChangeToPlace:)])
            {
                [[self delegate] placePickerController:self didChangeToPlace:lastLocation];
            }
        }
    }];
}

/**
 *  Stops the automatic updates.
 *
 *  Called whenever the user chooses a location from the list.
 */

- (void)disableAutomaticUpdates
{
    self.automaticUpdates = NO;
    [[MBLocationManager sharedManager] stopUpdatingLocation];
}

#pragma mark - UITableViewDataSource

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
    
    /**
     *  Disable automatic updates.
     */
    
    [self disableAutomaticUpdates];
    
    /**
     *  Pull out a location from the list.
     */
    
    NSDictionary *location = self.unsortedLocationList[indexPath.row];
    
    /**
     *  If the locations are sorted by continent, 
     *  pull out the appropriate one.
     */
    
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
    CLLocation *place = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    /**
     *  Assign the location to the picker.
     */
    
    self.location = place;
    
    /**
     *  Call the delegate method with the place.
     */
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(placePickerController:didChangeToPlace:)]) {
        [self.delegate placePickerController:self didChangeToPlace:place];
    }
    
    /**
     *  Update the map.
     */
    
    [self.map markCoordinate:coordinate];
    
    /**
     *  Update the list.
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
    
    if (url)
    {
        
        [[CRLCoreLib networkManager] downloadDataAtURL:url withCompletion:^(NSData *data) {
            if (data)
            {
                NSError *error = nil;
                NSArray *locations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                
                if (error && ! locations)
                {
                    NSLog(@"MBPlacePicker (CRLCoreLib): Failed to unwrap fresh location list.");
                }
                else if (locations)
                {
                    if (!locations.count) {
                        NSLog(@"MBPlacePicker (CRLCoreLib): Recieved an empty list of locations.");
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
                NSLog(@"MBPlacePicker (CRLCoreLib): Failed to download fresh location list.");
            }
        }];
    }
    else
    {
        NSLog(@"Failed to update locations from server. Invalid URL.");
    }
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

/**
 *  Sets the current location and update the map.
 *  Setting this property does not call the delegate.
 *
 *  @param location The location to display.
 */

- (void)setLocation:(CLLocation *)location
{
    _location = location;
    
    if (location)
    {
        [self disableAutomaticUpdates];
        [self.map markCoordinate:location.coordinate];
        
        NSDictionary *newLocationData = @{@"latitude": @(location.coordinate.latitude), @"longitude" : @(location.coordinate.longitude)};
        [[NSUserDefaults standardUserDefaults] setObject:newLocationData forKey:kLocationPersistenceKey];
    }
}

@end
