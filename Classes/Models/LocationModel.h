//
//  LocationModel.h
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^OperationFinishedBlock)(NSArray *locations, NSError *error);


@interface LocationModel : NSObject

@property (nonatomic, strong) NSString *locationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSString *imageString;
@property (nonatomic, assign) BOOL isLocationSelected;
@property (nonatomic, strong) NSString *category;

+ (void)getLocationFromFourSquareWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block;

-(instancetype)initWithLocationData:(NSDictionary *)dataDic;

+ (void)autocompleteFourSquarePlacesWithText:(NSString *)text withCompletion:(OperationFinishedBlock)block;

+ (void)getSearchedLocationWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block;

@end
