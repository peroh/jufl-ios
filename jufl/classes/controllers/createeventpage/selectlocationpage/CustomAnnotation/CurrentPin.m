//
//  CurrentPin.m
//  JUFL
//
//  Created by Ankur on 15/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "CurrentPin.h"

@implementation CurrentPin

- (instancetype)initWithTitle:(NSString *)myTitle pinNumber:(NSString *)number location:(CLLocationCoordinate2D)myLocation
{
    self = [super init];
    if(self)
    {
        _title = myTitle;
        _coordinate = myLocation;
        _pinNumber = number;
    }
    return self;
}

-(MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:[CurrentPin reuseIdentifier]];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    return annotationView;
}

+ (NSString *)reuseIdentifier
{
    return @"CurrentPin";
}


@end
