//
//  MyCustomAnnotation.m
//  AroundAbout
//
//  Created by Sashi Bhushan on 12/01/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import "MyCustomAnnotation.h"

@implementation MyCustomAnnotation

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
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:[MyCustomAnnotation reuseIdentifier]];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.backgroundColor = [UIColor redColor];
    // Create label for annotation pin.
    UILabel *pinNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 15)];
    pinNumberLabel.backgroundColor = [UIColor clearColor];
    pinNumberLabel.textColor = [UIColor whiteColor];
    pinNumberLabel.font = FONT_ProximaNova_Bold_WITH_SIZE(10.0);
    pinNumberLabel.text = self.pinNumber;
    [pinNumberLabel sizeToFit];
    [annotationView addSubview:pinNumberLabel];
    annotationView.frame = CGRectMake(0, 0, 16, 16);
    pinNumberLabel.center = annotationView.center;
    annotationView.layer.cornerRadius = 8;
    return annotationView;
}

+ (NSString *)reuseIdentifier
{
    return @"MyAnnotation";
}

@end
