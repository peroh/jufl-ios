//
//  LocationModel.m
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "LocationModel.h"

@implementation LocationModel


////////1
+ (void)getNearbyPlacesWithGivenLocationFromGoogleAPIWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block {
    
    if([Location isLocationServiceOn])
    {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        
        [Connection callGooglPlaceServiceWithName:kGoogleNearbySearchAPI postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSArray *resultsArray = [((NSDictionary *)response) objectForKey:@"results"];
                if(resultsArray.count>0)
                {
                        NSArray *result = [self getVenuesGoogleAPIData:resultsArray];
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

+(NSArray *)getVenuesGoogleAPIData:(NSArray *)items
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i<items.count; i++) {
        NSDictionary *dic = (NSDictionary *)items[i];
        LocationModel *location = [[[self class] alloc] initWithGoogleAPIData:dic];
        
        if(location)
            [dataArray addObject:location];
    }
    
 
    for (int i = 0; i < dataArray.count; i++) {
        LocationModel *location = dataArray[i];
        location.name = [NSString stringWithFormat:@"%i. - %@",i+1,location.name];
    }
    
    return [NSArray arrayWithArray:dataArray];
}

-(instancetype)initWithGoogleAPIData:(NSDictionary *)dataDic
{
    self = [super init];//google palces
    if(self)
    {
        self.locationId = [dataDic objectForKey:@"id"];
        self.locationPlaceId = [dataDic objectForKey:@"place_id"];
        self.name = [dataDic objectForKey:@"name"];
        self.imageString = [dataDic objectForKey:@"icon"];
        self.address = [dataDic objectForKey:@"vicinity"];
        NSDictionary *locationDetails = [[dataDic objectForKey:@"geometry"] objectForKey:@"location"];
        if(locationDetails)
        {
            self.coordinate = CLLocationCoordinate2DMake([[locationDetails objectForKey:@"lat"] doubleValue], [[locationDetails objectForKey:@"lng"] doubleValue]);
            self.distance = 0;
            NSString *addressStr = [dataDic objectForKey:@"vicinity"];
            NSArray *cityArr = [addressStr componentsSeparatedByString:@","];
            self.city = [cityArr lastObject];
            self.country = @"";
            
            self.isLocationSelected = NO;
        }
  
    }
    return self;
}


///////////////////////////////////////////////

/////2

+ (void)autocompleteGooglePlacesWithText:(NSString *)text withCompletion:(OperationFinishedBlock)block{
    if([Location isLocationServiceOn])
    {
        //https://maps.googleapis.com/maps/api/place/autocomplete/json?location=19.017615,72.856164&input=Vict&key=AIzaSyB0EAoRACMQPUoiPheg-nKQi3cJx6Ot1MI
        NSDictionary *params = @{@"key":kGoogleApiKey,@"radius":kRadius,@"location":kGoogleLatLong,@"input":text};
        [Connection callGooglPlaceServiceWithName:kGoogleAutocompleteAPI postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSArray *autoCompResultArray = [((NSDictionary *)response) objectForKey:@"predictions"];
                if(autoCompResultArray.count>0)
                {
                    NSArray *result = [self getGoogleAutocompleteArray:autoCompResultArray];
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
+ (NSArray *)getGoogleAutocompleteArray:(NSArray *)items
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i<items.count; i++) {
        NSDictionary *dic = (NSDictionary *)items[i];
        LocationModel *location = [[[self class] alloc] initWithGoogleAutocompleteData:dic];
        
        if(location)
            [dataArray addObject:location];
    }
    
   
    return [NSArray arrayWithArray:dataArray];
    
}


-(instancetype)initWithGoogleAutocompleteData:(NSDictionary *)dataDic
{
    self = [super init];//google Autocomplete
    if(self)
    {
        self.locationId = [dataDic objectForKey:@"id"];
        self.locationPlaceId = [dataDic objectForKey:@"place_id"];
        NSArray *nameArr = (NSArray*)[dataDic objectForKey:@"terms"] ;
        self.name = [[nameArr firstObject] objectForKey:@"value"];
        if (self.name.length<3 && nameArr.count>1) {
            self.name = [NSString stringWithFormat:@"%@ %@",self.name,[[nameArr objectAtIndex:1] objectForKey:@"value"]];
        }
        self.imageString = @"";
        self.address = [dataDic objectForKey:@"description"];
        
        NSArray *addArr = [dataDic objectForKey:@"terms"];
        if (addArr.count>2) {
            self.city = [[addArr objectAtIndex:addArr.count-2] objectForKey:@"value"];
        }
        else{
         self.city = @"";
        }
        self.distance = 0;
        self.country = [[addArr lastObject] objectForKey:@"value"];
        self.isLocationSelected = NO;
    }
    return self;
}

/////////////////////////

/////3
+ (void)getSeartchTextPlacesWithGivenLocationFromGoogleAPIWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block {
    
    if([Location isLocationServiceOn])
    {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        
        [Connection callGooglPlaceServiceWithName:kGoogleSearchTextAPI postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSArray *resultsArray = [((NSDictionary *)response) objectForKey:@"results"];
                if(resultsArray.count>0)
                {
                    NSArray *result = [self getVenuesGoogleAPISearchTextData:resultsArray];
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

+(NSArray *)getVenuesGoogleAPISearchTextData:(NSArray *)items
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i<items.count; i++) {
        NSDictionary *dic = (NSDictionary *)items[i];
        LocationModel *location = [[[self class] alloc] initWithGoogleAPISearchTextData:dic];
        
        if(location)
            [dataArray addObject:location];
    }
    
    for (int i = 0; i < dataArray.count; i++) {
        LocationModel *location = dataArray[i];
        location.name = [NSString stringWithFormat:@"%i. - %@",i+1,location.name];
    }
    
    return [NSArray arrayWithArray:dataArray];
}

-(instancetype)initWithGoogleAPISearchTextData:(NSDictionary *)dataDic
{
    self = [super init];//google search text
    if(self)
    {
        self.locationId = [dataDic objectForKey:@"id"];
        self.locationPlaceId = [dataDic objectForKey:@"place_id"];
        self.name = [dataDic objectForKey:@"name"];
        self.imageString = [dataDic objectForKey:@"icon"];
        self.address = [dataDic objectForKey:@"formatted_address"];
        NSDictionary *locationDetails = [[dataDic objectForKey:@"geometry"] objectForKey:@"location"];
        if(locationDetails)
        {
            self.coordinate = CLLocationCoordinate2DMake([[locationDetails objectForKey:@"lat"] doubleValue], [[locationDetails objectForKey:@"lng"] doubleValue]);
            self.distance = 0;
            NSString *addressStr = [dataDic objectForKey:@"formatted_address"];
            NSArray *cityArr = [addressStr componentsSeparatedByString:@","];
            self.city = @"";
            self.country = [cityArr lastObject];
            
            self.isLocationSelected = NO;
        }
        
    }
    return self;
}



////////////////
//////4
+ (void)getPlaceDetailFromGoogleAPIWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block {
    
    if([Location isLocationServiceOn])
    {
        //[Utils startActivityIndicatorWithMessage:kPleaseWait];
        
        [Connection callGooglPlaceServiceWithName:kGooglePlaceDetailsAPI postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSDictionary *aDictLocation=[((NSDictionary *)response) objectForKey:@"result"];
               
                NSArray *resultsArray = [NSArray arrayWithObject:aDictLocation];
                if(resultsArray.count>0)
                {
                    block(resultsArray,error);
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
//////5
+ (void)getPlacePhotosFromGoogleAPIWithParams:(NSDictionary *)params completion:(OperationFinishedBlock)block {
    
    if([Location isLocationServiceOn])
    {
        [Utils startActivityIndicatorWithMessage:kPleaseWait];
        
        [Connection callGooglPlaceServiceWithName:kGooglePlacePhotoAPI postData:params callBackBlock:^(id response, NSError *error) {
            [Utils stopActivityIndicatorInView];
            if(response)
            {
                NSArray *resultsArray = [((NSDictionary *)response) objectForKey:@"results"];
                if(resultsArray.count>0)
                {
                    NSArray *result = [self getVenuesGoogleAPIData:resultsArray];
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
/////////////////
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
