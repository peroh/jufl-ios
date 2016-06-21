//
//  AFSharedClient.h
//  GarbageBin
//
//  Created by Naveen Rana on 30/06/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//
//
// 131 - client

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Configuration.h"

// Base URL Currently Used -


#define kBaseURL [Configuration getBaseURL]

#define kFourSquareBaseURL @"https://api.foursquare.com/v2/"

#define kGooglePlaceBaseURL @"https://maps.googleapis.com/maps/api/place"


@interface AFSharedClient : AFHTTPSessionManager

+ (instancetype)sharedClient;
+ (instancetype)sharedGoogleClient;

@end
