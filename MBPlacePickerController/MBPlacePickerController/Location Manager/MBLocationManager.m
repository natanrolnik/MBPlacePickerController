//
//  MBLocationManager.m
//  MBLocationManager
//
//  Created by Moshe on 5/21/14.
//
//

#import "MBLocationManager.h"

@interface MBLocationManager () <CLLocationManagerDelegate>

/**
 *  A CLLocationManager
 */

@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 *  The newest collection of locations returned by the location manager.
 */

@property (nonatomic, strong) NSArray *locations;

/**
 *  The newest heading data.
 */

@property (nonatomic, strong) CLHeading *heading;

/**
 *  The latest authorization status.
 */

@property (nonatomic, assign) CLAuthorizationStatus status;

/**
 *  The completion handler for location or heading updates.
 */

@property (nonatomic, strong) MBLocationManagerUpdateCompletionBlock completion;

@end

@implementation MBLocationManager

#pragma mark - Singleton Access

/** ---
 *  @name Singleton Access
 *  ---
 */

/**
 *  Singleton access.
 */

+ (MBLocationManager *)sharedManager
{
    static MBLocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MBLocationManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Initializer

/** ---
 *  @name Intializer
 *  ---
 */
 
/**
 *  Designated initializer.
 */

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _heading = nil;
        _locations = nil;
    }
    return self;
}

#pragma mark - Core Location Manager Delegate

/** ----
 *  @name Core Location Manager Delegate
 *  ----
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self setLocations:locations];
    
    if (self.completion) {
        self.completion(self.locations, self.heading, self.status);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self setHeading:newHeading];
    
    if (self.completion) {
        self.completion(self.locations, self.heading, self.status);
    }
}

#pragma mark - Getting Location/Heading

/** ----
 *  @name Getting Location/Heading
 *  ----
 */

/**
 *  Update the user's location with a completion block.
 *
 *  Will prompt the user for permission the first time.
 */

- (void)updateLocationWithCompletionHandler:(MBLocationManagerUpdateCompletionBlock)completion
{
    [self setCompletion:completion];
    [[self locationManager] startUpdatingLocation];
}

/**
 *  Stop updating the locations.
 */

- (void)stopUpdatingLocation
{
    [[self locationManager] stopUpdatingLocation];
}

/**
 *  The last known location of the location manager.
 */

- (CLLocation *)location
{
    CLLocation * l = nil;
    
    if ([[self locations] count]) {
        l = [self locations][0];
    }
    return l;
}

@end
