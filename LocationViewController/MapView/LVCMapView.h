//
//  LVCMapView.h
//  LocationViewController
//
//  Created by Moshe on 6/30/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;

@interface LVCMapView : UIImageView

/**
 *  Converts a latitude and longitude to a CGPoint in the map view's coordinate space.
 *
 *  @param latitude The latitude to use.
 *  @param longiutde The longitude to use.
 *
 *  @return A CGPoint in the view's coordinate space.
 */

- (CGPoint)pointFromLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude;

/**
 *  Converts a local coordinate plane point to a lat/lon point.
 *
 *  @param point A CGPoint in the map's coordinate space.
 */

- (CLLocationCoordinate2D)coordinateFromPoint:(CGPoint)point;

/**
 *  Displays a marker on the given coordinate.
 */

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  The color of the location marker. 
 *
 *  @discussion The default is red. Setting to nil will default to red.
 */

@property (nonatomic, strong) UIColor *markerColor;

/**
 *  The radius of the indicator. The default is 30.0f;
 *   Setting to a negative will do nothing.
 */

@property (nonatomic, assign) CGFloat markerDiameter;

@end
