//
//  MyCustomAnnotation.h
//  AroundAbout
//
//  Created by Sashi Bhushan on 12/01/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyCustomAnnotation : NSObject<MKAnnotation>

@property (assign,nonatomic) CLLocationCoordinate2D coordinate;
@property (copy,nonatomic) NSString *title;
@property (nonatomic, strong) NSString *pinNumber;
@property (assign,nonatomic) NSInteger tag;

+ (NSString *)reuseIdentifier;

- (instancetype)initWithTitle:(NSString *)myTitle pinNumber:(NSString *)number location:(CLLocationCoordinate2D)myLocation;

- (MKAnnotationView *)annotationView;

@end
