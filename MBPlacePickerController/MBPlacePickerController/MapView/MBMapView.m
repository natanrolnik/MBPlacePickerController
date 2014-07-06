//
//  LVCMapView.m
//  LocationViewController
//
//  Created by Moshe on 6/30/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "MBMapView.h"
#import "MBLocationManager.h"

@interface MBMapView ()

/**
 *  References the last known coordinate.
 */

@property (nonatomic, assign) CLLocationCoordinate2D lastCoordinate;

@end

/**
 *  This view is capable of displaying markers on a map.
 */

@implementation MBMapView

#pragma mark - Initializers

/** ---
 *  @name Initializers
 *  ---
 */

/**
 *  @return An initialized map picker view.
 */

- (instancetype)init
{
    self = [super initWithImage:[UIImage imageNamed:@"equi-map"]];
    if (self)
    {
        _markerDiameter = 30.0f;
        _markerColor = [UIColor redColor];
        _showUserLocation = NO;
    }
    return self;
}

- (void)didMoveToSuperview
{
    if (self.showUserLocation)
    {
        [self _updateUserLocation];
    }
}

- (void)removeFromSuperview
{
    [[self marker] removeFromSuperview];

    [super removeFromSuperview];
}

#pragma mark - Converting between UIKit Coordinates and Geographical Coordinates

/** ---
 *  @name Converting between UIKit Coordinates and Geographical Coordinates
 *  ---
 */

/**
 *  Converts a latitude and longitude to a CGPoint in the map view's coordinate space.
 *
 *  @param latitude The latitude to use.
 *  @param longiutde The longitude to use.
 *
 *  @return A CGPoint in the view's coordinate space.
 */

- (CGPoint)pointFromLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude
{
    CGRect bounds = self.bounds;
    
    CGFloat longitudeFraction = longitude/180.0f;
    CGFloat longitudeAsPoint = longitudeFraction * CGRectGetMidX(bounds);
    
    CGFloat latitudeFraction = -(latitude/90.0f);
    CGFloat latitudeAsPoint = latitudeFraction * CGRectGetMidY(bounds);
    
    CGFloat midX = CGRectGetMidX(bounds);
    CGFloat midY = CGRectGetMidY(bounds);
    
    CGPoint center = CGPointMake(longitudeAsPoint + midX, latitudeAsPoint + midY);
    
    return center;
}

/**
 *  Converts a local coordinate plane point to a lat/lon point.
 *
 *  @param point A CGPoint in the map's coordinate space.
 */

- (CLLocationCoordinate2D)coordinateFromPoint:(CGPoint)point
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    CGFloat xDistanceFromCenter = center.x - point.x;
    CGFloat yDistanceFromCenter = center.y - point.y;
    
    CGFloat xRatio = xDistanceFromCenter/CGRectGetMidX(bounds);
    CGFloat yRatio = yDistanceFromCenter/CGRectGetMidY(bounds);
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(90*yRatio, 180*xRatio);
    
    return coord;
}

#pragma mark - Getting Marker Views

/** ---
 *  @name Getting Marker Views
 *  ---
 */
/**
 *  A marker for a location.
 */

- (UIView *)marker
{
    static UIView *marker = nil;
    
    if (!marker)
    {
        /**
         *  An outer ring
         */
        
        marker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.markerDiameter, self.markerDiameter)];
        marker.layer.borderWidth = 1.0f;
        marker.layer.cornerRadius = CGRectGetHeight(marker.bounds)/2.0f;
        
        /**
         *  An innermost ring
         */
    }
    
    marker.layer.borderColor = [self.markerColor CGColor];
    marker.backgroundColor = [self.markerColor colorWithAlphaComponent:0.7];
    

    return marker;
}

/**
 *  @return A marker representing the user's location.
 */

- (UIView *)userMarker
{
    static UIView *marker = nil;
    
    if (!marker)
    {
        marker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15.0f, 15.0f)];
        marker.layer.borderWidth = 1.0f;
        marker.layer.cornerRadius = CGRectGetHeight(marker.bounds)/2.0f;
    }
    
    marker.layer.borderColor = self.tintColor.CGColor;
    marker.backgroundColor = [[UIColor colorWithCGColor:marker.layer.borderColor] colorWithAlphaComponent:0.7];
    
    return marker;
}

#pragma mark -  Displaying Markers

/** ---
 *  @name Displaying Markers
 *  ---
 */

/**
 *  Displays a marker on the given coordinate.
 */

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint center = [self pointFromLatitude:coordinate.latitude andLongitude:coordinate.longitude];
    
    UIView *marker = [self marker];

    marker.layer.cornerRadius = self.markerDiameter/2.0f;
    
    if (![self.subviews containsObject:[self marker]])
    {
        marker.frame = CGRectMake(0, 0, 0, 0);
        
        [marker setAlpha:0.0f];
        [marker setCenter:center];
    }
    else
    {
        CGRect markerRect = marker.frame;
        markerRect.size = CGSizeMake(self.markerDiameter, self.markerDiameter);
        marker.frame = markerRect;
    }
    
    [self addSubview:marker];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect markerRect = marker.frame;
        markerRect.size = CGSizeMake(self.markerDiameter, self.markerDiameter);
        marker.frame = markerRect;
        [marker setCenter:center];
        [marker setAlpha:1.0];
    }];
    
    self.lastCoordinate = coordinate;
}

/**
 *  Refresh the marker with new settings.
 */

- (void)refreshMarker
{
    [self markCoordinate:self.lastCoordinate];
}

#pragma mark - Custom Setters

/** ---
 *  @name Custom Setters
 *  ---
 */

/**
 *  Set the location marker's color.
 *
 *  @discussion Setting to nil will default to red.
 *
 *  @param indicatorColor The color to change the indicator to.
 */

- (void)setMarkerColor:(UIColor *)markerColor
{
    if (!markerColor)
    {
        markerColor = [UIColor redColor];
    }
    _markerColor = markerColor;
    
    [self refreshMarker];
}

/**
 *  Set the indicator radius. Setting to a negative will do nothing.
 */

- (void)setMarkerDiameter:(CGFloat)markerRadius
{
    if (markerRadius < 0)
    {
        return;
    }
    _markerDiameter = markerRadius;
    
    [self refreshMarker];
}

/**
 *  @param showUserLocation A parameter controlling wether to show the user's location.
 */

- (void)setShowUserLocation:(BOOL)showUserLocation
{
    _showUserLocation = showUserLocation;
    
    if (_showUserLocation)
    {
        [self _updateUserLocation];
    }
    else
    {
        [[self userMarker] removeFromSuperview];
        [[MBLocationManager sharedManager] stopUpdatingLocation];
    }
}

#pragma mark - Update User Location

/**
 *  Updates the user's location and shows the marker when the location manager returns fresh data.
 */

- (void)_updateUserLocation
{
    
    [[MBLocationManager sharedManager] updateLocationWithCompletionHandler:^(NSArray *locations, CLHeading *heading, CLAuthorizationStatus authorizationStatus) {

            CLLocation *location = [[MBLocationManager sharedManager] location];
            
            if (location) {
                CGPoint userMarkerCenter = [self pointFromLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude];
                [[self userMarker] setCenter:userMarkerCenter];
                [self addSubview:[self userMarker]];
            }
            

    }];

}
@end
