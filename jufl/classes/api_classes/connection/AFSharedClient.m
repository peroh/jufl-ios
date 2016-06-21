//
//  AFSharedClient.m
//  GarbageBin
//
//  Created by Naveen Rana on 30/06/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//

#import "AFSharedClient.h"
@implementation AFSharedClient

+ (instancetype)sharedClient {
    static AFSharedClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFSharedClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        _sharedClient.requestSerializer=[AFHTTPRequestSerializer serializer];
        _sharedClient.responseSerializer=[AFJSONResponseSerializer serializer];
        
        
    });
    
    return _sharedClient;
}
+ (instancetype)sharedGoogleClient {
    static AFSharedClient *_sharedGoogleClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGoogleClient = [[AFSharedClient alloc] initWithBaseURL:[NSURL URLWithString:kGooglePlaceBaseURL]];//kFourSquareBaseURL
        _sharedGoogleClient.requestSerializer=[AFJSONRequestSerializer serializer];
        _sharedGoogleClient.responseSerializer=[AFJSONResponseSerializer serializer];
        
        
    });
    
    return _sharedGoogleClient;
}

@end
