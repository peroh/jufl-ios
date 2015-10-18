

#import "Location.h"


#define kLocationOnSettingMessage     @"Please check your location settings via Settings->Privacy->Location Services"


@implementation Location
@synthesize reverseGeocodeBlock;

+ (Location*)sharedInstance
{
    static Location *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Location alloc] init];
    });
    
    return sharedInstance;
}



-(CLLocationCoordinate2D)getCoordinates
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    
    CLLocationCoordinate2D coord;
    coord = [location coordinate];
    return coord;
}



- (CLLocationDistance)getDistanceBetweenTwoCordinates:(double)lat1 longitude1:(double)long1  latitude2:(double)lat2 longitude2:(double)long2
{
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:lat1 longitude:long1];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:lat2   longitude:long2];
    CLLocationDistance distance = [location1 distanceFromLocation:location2];
    location1=nil;
    location2=nil;
    return distance;
}


#pragma mark GeoCoding Methods
- (void)getCordinatesFromAddress:(NSString*)addressString responseBlock:(void(^)(CLLocation *cordinate))locationBlock
{
   
    NSString *req=[NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@",addressString];
    req=[req stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:req]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *reponse, NSData *responseData, NSError *error)
    {
        
        NSError *err = nil;
        
        if(responseData)
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&err];
        
        //DLog(@"dict %@",dict);
        
        NSDictionary *latLongDict = [[[[dict objectForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"] lastObject];
        if(latLongDict.count>0)
        {
        CLLocation *coordinate=[[CLLocation alloc] initWithLatitude:[[latLongDict valueForKey:@"lat"] doubleValue] longitude:[[latLongDict valueForKey:@"lng"] doubleValue]];
        locationBlock(coordinate);
        }
        else
            locationBlock(nil);
        
        }
    }];
}


#pragma mark ReverseGeocoding Methods

- (void)getAddressInfoFromLocationLatitude:(double)latCord longitude:(double)longCord completionBlock:(void(^)(CLPlacemark *placeMark))adrressBlock
{
    CLLocation *location = [[CLLocation alloc]initWithLatitude:latCord longitude:longCord];
    self.reverseGeocodeBlock = adrressBlock;
    if([[UIDevice currentDevice].systemVersion floatValue] >= 5.0)
    {
         __block CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:
         ^(NSArray* placemarks, NSError* error)
         {
             if ([placemarks count] > 0)
             {
                 CLPlacemark *placeMark = [placemarks objectAtIndex:0];
                 adrressBlock(placeMark);
                 geocoder=nil;

             }else
             {
                 adrressBlock(nil);
                 geocoder=nil;
             }
         }];
        //[geocoder retain];
        //location=nil;
        //[geocoder release];
    }else
    {
//        MKReverseGeocoder* geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
//        geocoder.delegate = self;
//        [geocoder start];
    }
    //[location release];
}

#pragma mark ReverseGeoCoder Delagate
//- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)place
//{
//    self.reverseGeocodeBlock(place.addressDictionary);
//    [self.reverseGeocodeBlock release];
//    [geocoder release];
//}
//
//- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error
//{
//    self.reverseGeocodeBlock(nil);
//    [self.reverseGeocodeBlock release];
//    [geocoder release];
//}


#pragma mark ReverseGeoCodingUsing GoogleAPI

- (void)getAddressInfoFromGoogleApiLatitude:(double)latCord longitude:(double)longCord completionBlock:(void(^)(NSDictionary * addressDic))block
{
    NSString *requestUrl=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false",latCord,longCord];
    requestUrl = [requestUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:60];
    [request setURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/JSON" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse* response = nil;
    NSError* error = nil;
    //NSString *responseString = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    if (error)
    {
        block(nil);
        
    }else
    {
        //responseString  = [[NSString alloc]initWithData:result encoding:NSASCIIStringEncoding];
        NSMutableDictionary *dicResult  = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        if(!dicResult||([dicResult count]==0))
        {
            block(nil);
            return;
        }
        if ([[dicResult objectForKey:@"status"] isEqualToString:@"OK"])
        {
            NSArray *arrayResult = [dicResult objectForKey:@"results"];
            if ([arrayResult count]>0)
            {
                block([arrayResult objectAtIndex:0]);
            }else
            {
                block(nil);
            }
        }else
        {
            block(nil);
        }
        //[responseString release];
    }
}


#pragma mark - Get current location of user

-(void)startUpdateLocation
{
    [_locationManager startUpdatingLocation];
}
+(BOOL)isLocationServiceOn
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if(status == kCLAuthorizationStatusDenied)
    {
        [Utils showOKAlertWithTitle:kTitle message:kLocationOnSettingMessage];
        return NO;
    }
    return YES;

}
-(void)initLocationManager
{
    if(![Location isLocationServiceOn])return;
    /*
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
        return;
    }*/
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){ //iOS 7
        if (_locationManager) {
            //[_locationManager release];
            _locationManager=nil;
        }
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        _locationManager.distanceFilter = 100.0f;
        [_locationManager startUpdatingLocation];
    }
    else // iOS 8
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        //[self.locationManager startUpdatingLocation];
       // [self._locationManager requestAlwaysAuthorization]
    
    }

    

	/*if(![CL_locationManager locationServicesEnabled])
	{

	}
    else{
	[_locationManager startUpdatingLocation];
       
    }*/
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways )
    {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    
    if(locations.count==0)return;
    CLLocation *newLocation = [locations lastObject];
    CLLocationCoordinate2D location = newLocation.coordinate;
    self.userCurrentLocation = location;
    self.location = newLocation;
    
   // [self.locationManager stopUpdatingLocation];

   // [UserDefaluts setObject:[NSString stringWithFormat:@"%f",location.latitude] forKey:kLatitude];
    //[UserDefaluts setObject:[NSString stringWithFormat:@"%f",location.longitude] forKey:kLongitude];

       
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
      DLog(@"%@",error);
    
    CLLocationDegrees latitude=0.00000;
	CLLocationDegrees longitude=0.00000;
    CLLocation *location=[[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    self.userCurrentLocation=location.coordinate;
    location=nil;
    
}

-(void)getLocation :(void(^)(BOOL success))block
{
    if((self.userCurrentLocation.latitude == 0.00000) && (self.userCurrentLocation.longitude == 0.00000))
    {
//        [Utils showOKAlertWithTitle:kTitle message:@"MellToo requires your location."];
        block(FALSE);

        return;
    }
    
    
    [self getAddressInfoFromLocationLatitude:self.userCurrentLocation.latitude longitude:self.userCurrentLocation.longitude completionBlock:^(CLPlacemark *placeMark) {
        
        if(placeMark)
        {
            NSString *userLocation=@"";
            if(placeMark.locality)
            {
                userLocation=[NSString stringWithFormat:@"%@, %@",NULLVALUE(placeMark.locality),NULLVALUE(placeMark.country)];

            }
            else
            {
                userLocation=[NSString stringWithFormat:@"%@, %@",NULLVALUE(placeMark.administrativeArea),NULLVALUE(placeMark.country)];

            }
            /*NSMutableString *userLocation = [NSMutableString stringWithString:@""];
            for (int i = 0; i<[[addressDic objectForKey:@"FormattedAddressLines"]count]; i++)
            {
                
                NSString * str = [[addressDic objectForKey:@"FormattedAddressLines"] objectAtIndex:i];
                if(i == 0)
                    userLocation = [[userLocation stringByAppendingString:str] mutableCopy] ;
                else
                    userLocation = [[userLocation stringByAppendingString:[NSString stringWithFormat:@",%@",str]] mutableCopy] ;
                
            }*/
            
            //[UserDefaluts setObject:userLocation forKey:kLocation];
            block(TRUE);
        }
        else{
            //[UserDefaluts setObject:@"" forKey:kLocation];

            block(FALSE);
        }
        
    }];

}

+(NSString *)getCityCountryNameForPrediction:(NSDictionary *)predictDict
{
    NSString *finalString=@"";
    NSArray *termsArray=[predictDict objectForKey:@"terms"];
    if([termsArray count]>=3)
    {
        NSInteger index=[termsArray indexOfObject:[termsArray lastObject]];
        NSDictionary *tempCountryDict=[termsArray objectAtIndex:index];
        NSDictionary *tempCityDict=[termsArray objectAtIndex:index-2];
        finalString=[NSString stringWithFormat:@"%@, %@",[tempCityDict objectForKey:@"value"],[tempCountryDict objectForKey:@"value"]];

    }
    else
    {
        finalString=[predictDict objectForKey:@"description"];
    }
    return finalString;
}

@end
