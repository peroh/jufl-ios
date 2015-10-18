//
//  LocationModel.m
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "LocationModel.h"

@implementation LocationModel

+ (void)getLocationFromFourSquareWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block {
    if([Location isLocationServiceOn])
    {
        //        @"query" : @"bar"
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        
        [Connection callFourSquareServiceWithName:kFourSquareVenueExploreUrl postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSArray *groupsArray = [((NSDictionary *)[((NSDictionary *)response) objectForKey:@"response"]) objectForKey:@"groups"];
                if(groupsArray.count>0)
                {
                    NSDictionary *dataDic = groupsArray[0];
                    NSArray *itemsArray = [dataDic objectForKey:@"items"];
                    if(itemsArray.count>0)
                    {
                        NSArray *result = [self getVenuesFromFourSquareData:itemsArray];
                        block(result,error);
                    }
                    else
                        block(nil,error);
                }
                else
                    block(nil,error);
            }
            else
            {
                block(nil,error);
                
            }
        }];
        
    }
}

+ (void)getSearchedLocationWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block {
    if([Location isLocationServiceOn])
    {
        //        @"query" : @"bar"
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        
        [Connection callFourSquareServiceWithName:kFSSearchVenue postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSArray *groupsArray = [((NSDictionary *)[((NSDictionary *)response) objectForKey:@"response"]) objectForKey:@"venues"];
                if(groupsArray.count>0)
                {
                    NSArray *result = [self getVenuesForSearchedData:groupsArray];
                    block(result,error);
                }
                else
                    block(nil,error);
            }
            else
            {
                block(nil,error);
                
            }
        }];
        
    }
}
+ (void)autocompleteFourSquarePlacesWithText:(NSString *)text withCompletion:(OperationFinishedBlock)block{
    if([Location isLocationServiceOn])
    {
        //        @"query" : @"bar"
        NSDictionary *params = @{@"ll":kFourSquareLatLong,@"client_id":kFourSquareClientID, @"client_secret":kFourSquareClientSecret, kFourSquareVersion:kFourSquareVersionIdentifier, KRadiusKey : @"50000", @"query":text};
        [Connection callFourSquareServiceWithName:kFSAutocomplete postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSArray *groupsArray = [((NSDictionary *)[((NSDictionary *)response) objectForKey:@"response"]) objectForKey:@"minivenues"];
                if(groupsArray.count>0)
                {
                    //                    NSDictionary *dataDic = groupsArray[0];
                    //                    NSArray *itemsArray = [dataDic objectForKey:@"items"];
                    //                    if(itemsArray.count>0)
                    //                    {
                    NSArray *result = [self getAutocompleteArray:groupsArray];
                    block(result,error);
                    //                    }
                    //                    else
                    //                        block(nil,error);
                }
                else
                    block(nil,error);
            }
            else
            {
                block(nil,error);
                
            }
        }];
        
    }
}

+ (NSArray *)getAutocompleteArray:(NSArray *)items {
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i<items.count; i++) {
        NSDictionary *dic = (NSDictionary *)items[i];
        LocationModel *location = [[[self class] alloc] initWithFourSquareAutocompleteData:dic];
        
        if(location)
            [dataArray addObject:location];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        return ((((NSNumber *)obj1).intValue)>(((NSNumber *)obj2).intValue));
    }];
    
    NSArray *sortedArray = [dataArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    return [NSArray arrayWithArray:sortedArray];
    
}

+(NSArray *)getVenuesForSearchedData:(NSArray *)items
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i<items.count; i++) {
        NSDictionary *dic = (NSDictionary *)items[i];
        LocationModel *location = [[[self class] alloc] initWithFourSquareAutocompleteData:dic];
        
        if(location)
            [dataArray addObject:location];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        return ((((NSNumber *)obj1).intValue)>(((NSNumber *)obj2).intValue));
    }];
    
    NSArray *sortedArray = [dataArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (int i = 0; i < sortedArray.count; i++) {
        LocationModel *location = sortedArray[i];
        location.name = [NSString stringWithFormat:@"%i. - %@",i+1,location.name];
    }
    
    return [NSArray arrayWithArray:sortedArray];
}

+(NSArray *)getVenuesFromFourSquareData:(NSArray *)items
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i<items.count; i++) {
        NSDictionary *dic = (NSDictionary *)items[i];
        LocationModel *location = [[[self class] alloc] initWithFourSquareData:dic];
        
        if(location)
            [dataArray addObject:location];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        return ((((NSNumber *)obj1).intValue)>(((NSNumber *)obj2).intValue));
    }];
    
    NSArray *sortedArray = [dataArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (int i = 0; i < sortedArray.count; i++) {
        LocationModel *location = sortedArray[i];
        location.name = [NSString stringWithFormat:@"%i. - %@",i+1,location.name];
    }
    
    return [NSArray arrayWithArray:sortedArray];
}

-(instancetype)initWithFourSquareData:(NSDictionary *)dataDic
{
    self = [super init];
    if(self)
    {
        NSDictionary *venuedetails = [dataDic objectForKey:@"venue"];
        if(venuedetails)
        {
            self.name = [venuedetails objectForKey:@"name"];
            self.locationId = [venuedetails objectForKey:@"id"];
            NSDictionary *locationDetails = [venuedetails objectForKey:@"location"];
            NSDictionary *imageDetails = [venuedetails objectForKey:@"featuredPhotos"];
            if (imageDetails) {
                NSArray *photoArray = imageDetails[@"items"];
                if (photoArray.count) {
                    NSString *prefix = [photoArray firstObject][@"prefix"];
                    NSString *suffix = [photoArray firstObject][@"suffix"];
                    self.imageString = [NSString stringWithFormat:@"%@200x200%@",prefix,suffix];
                }
                
            }
            if(locationDetails)
            {
                self.coordinate = CLLocationCoordinate2DMake([[locationDetails objectForKey:@"lat"] doubleValue], [[locationDetails objectForKey:@"lng"] doubleValue]);
                
                self.distance = [locationDetails objectForKey:@"distance"];
                self.address = [locationDetails objectForKey:@"address"];
                self.city = [locationDetails objectForKey:@"city"];
                self.country = [locationDetails objectForKey:@"country"];
                self.isLocationSelected = NO;
            }
        }
    }
    return self;
}


-(instancetype)initWithFourSquareAutocompleteData:(NSDictionary *)dataDic
{
    self = [super init];
    if(self)
    {
        NSDictionary *venuedetails = dataDic;
        if(venuedetails)
        {
            self.name = [venuedetails objectForKey:@"name"];
            self.locationId = [venuedetails objectForKey:@"id"];
            NSArray *categoryArray = venuedetails[@"categories"];
            NSDictionary *locationDetails = [venuedetails objectForKey:@"location"];
            NSDictionary *imageDetails = [venuedetails objectForKey:@"featuredPhotos"];
            if (imageDetails) {
                NSArray *photoArray = imageDetails[@"items"];
                if (photoArray.count) {
                    NSString *prefix = [photoArray firstObject][@"prefix"];
                    NSString *suffix = [photoArray firstObject][@"suffix"];
                    self.imageString = [NSString stringWithFormat:@"%@200x200%@",prefix,suffix];
                }
                
            }
            if(locationDetails)
            {
                self.coordinate = CLLocationCoordinate2DMake([[locationDetails objectForKey:@"lat"] doubleValue], [[locationDetails objectForKey:@"lng"] doubleValue]);
                
                self.distance = [locationDetails objectForKey:@"distance"];
                self.address = [locationDetails objectForKey:@"address"];
                self.city = [locationDetails objectForKey:@"city"];
                self.country = [locationDetails objectForKey:@"country"];
                self.isLocationSelected = NO;
            }
            if (categoryArray.count) {
                self.category = [categoryArray firstObject][@"shortName"];
            }
        }
    }
    return self;
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

-(instancetype)initWithLocationData:(NSDictionary *)dict {
    self = [super init];
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.address = [self objectOrNilForKey:kLocationAddress fromDictionary:dict];
        //        self.locationId = [self objectOrNilForKey:kLocationId fromDictionary:dict];
        self.locationId = [self objectOrNilForKey:@"id" fromDictionary:dict];
        self.coordinate = CLLocationCoordinate2DMake([[self objectOrNilForKey:kLocationLat fromDictionary:dict] doubleValue], [[self objectOrNilForKey:kLocationLong fromDictionary:dict] doubleValue]);
        
        self.name = [self objectOrNilForKey:kEventName fromDictionary:dict];
        //        self.address = [self objectOrNilForKey:kLocationAddress fromDictionary:dict];
    }
    return self;
}
@end
