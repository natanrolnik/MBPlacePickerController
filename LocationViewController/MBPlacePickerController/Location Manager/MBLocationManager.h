//
//  MBLocationManager.h
//  MBLocationManager
//
//  Created by Moshe on 5/21/14.
//
//

#import <Foundation/Foundation.h>

@import CoreLocation;

typedef void(^MBLocationManagerUpdateCompletionBlock)(NSArray *locations, CLHeading *heading, CLAuthorizationStatus authorizationStatus);

@interface MBLocationManager : NSObject

/**
 *  Singleton access.
 */

+ (MBLocationManager *)sharedManager;

/**
 *  Update the user's location with a completion block.
 *
 *  Will prompt the user for permission the first time.
 */

- (void)updateLocationWithCompletionHandler:(MBLocationManagerUpdateCompletionBlock)completion;

/**
 *  Stop updating the locations.
 */

- (void)stopUpdatingLocation;

/**
 *  The last known location of the location manager.
 */

- (CLLocation *)location;

/**
 *  The last known heading of the location manager.
 */

- (CLHeading *)heading;

 
@end
