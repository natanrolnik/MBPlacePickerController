//
//  LVCMapView.m
//  LocationViewController
//
//  Created by Moshe on 6/30/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "LVCMapView.h"

@interface LVCMapView ()

/**
 *  References the last known coordinate.
 */

@property (nonatomic, assign) CLLocationCoordinate2D lastCoordinate;

@end

/**
 *  This view is capable of displaying markers on a map.
 */

@implementation LVCMapView

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
    }
    return self;
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
         *  A center ring
         */
        
//        UIView *centerRing = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.markerRadius*(2.0/3.0), self.markerRadius*(2.0/3.0))];
        
        
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
        marker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7.0, 7.0f)];
        marker.layer.borderWidth = 1.0f;
        marker.layer.cornerRadius = CGRectGetHeight(marker.bounds)/2.0f;
    }
    
    marker.layer.borderColor = [[UIView appearance] tintColor].CGColor;
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
    marker.frame = CGRectMake(0, 0, self.markerDiameter, self.markerDiameter);
    marker.layer.cornerRadius = self.markerDiameter/2.0f;
    
    [marker setAlpha:0.0f];
    [marker setCenter:center];
    
    
    [self addSubview:marker];
    [UIView animateWithDuration:0.3 animations:^{
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
@end
