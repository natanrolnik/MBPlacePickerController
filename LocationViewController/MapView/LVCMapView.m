//
//  LVCMapView.m
//  LocationViewController
//
//  Created by Moshe on 6/30/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "LVCMapView.h"

@interface LVCMapView ()

@end

@implementation LVCMapView

- (instancetype)init
{
    self = [super initWithImage:[UIImage imageNamed:@"map-iphone"]];
    if (self)
    {
        _indicatorRadius = 30.0f;
    }
    return self;
}

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

/**
 *  A marker for a location.
 */

- (UIView *)marker
{
    static UIView *marker = nil;
    
    if (!marker)
    {
        marker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.indicatorRadius, self.indicatorRadius
                                                          )];
        marker.layer.borderColor = [[UIColor redColor] CGColor];
        marker.layer.borderWidth = 1.0f;
        marker.layer.cornerRadius = CGRectGetHeight(marker.bounds)/2.0f;
        marker.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.7f];
    }
    
    return marker;
}

/**
 *  Displays a marker on the given coordinate.
 */

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint center = [self pointFromLatitude:coordinate.latitude andLongitude:coordinate.longitude];

    UIView *marker = [self marker];
    
    
    if (![self.subviews containsObject:marker]) {
        [marker setAlpha:0.0f];
        [marker setCenter:center];
    }
    
    [self addSubview:marker];
    [UIView animateWithDuration:0.3 animations:^{
        [marker setCenter:center];
        [marker setAlpha:1.0];
    }];

}

@end
