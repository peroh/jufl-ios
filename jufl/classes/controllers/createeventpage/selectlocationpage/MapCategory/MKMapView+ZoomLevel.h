//
//  MKMapView+ZoomLevel.h
//  JUFL
//
//  Created by Ankur on 15/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
