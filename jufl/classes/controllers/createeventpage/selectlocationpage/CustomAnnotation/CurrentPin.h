//
//  CurrentPin.h
//  JUFL
//
//  Created by Ankur on 15/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentPin : NSObject<MKAnnotation>

@property (assign,nonatomic) CLLocationCoordinate2D coordinate;
@property (copy,nonatomic) NSString *title;
@property (nonatomic, strong) NSString *pinNumber;
@property (assign,nonatomic) int tag;

+ (NSString *)reuseIdentifier;

- (instancetype)initWithTitle:(NSString *)myTitle pinNumber:(NSString *)number location:(CLLocationCoordinate2D)myLocation;

- (MKAnnotationView *)annotationView;

@end
