//
//  FeedModel.m
//  JUFL
//
//  Created by Ankur on 22/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "FeedModel.h"
#import "EventModel.h"


@implementation FeedModel

- (instancetype)initWithDictionary:(NSDictionary *)params {
    self = [super init];
    
    if (self) {
        if([params objectNonNullForKey:kPageNumber])
            self.nextPage = numberValue([params objectForKey:kPageNumber]);
        if ([params objectNonNullForKey:kUserEvents]) {
            self.results = [[NSMutableArray alloc]init];
            NSArray *arrResult = [params objectForKey:kUserEvents];
            for (NSDictionary *dict in arrResult) {
                EventModel *event  = [[EventModel alloc]initWithEventData:dict];
                [self.results addObject:event];
            }
        }
    }
    return self;
}

+ (void)getUserFeed:(NSDictionary *)params withSuccessBlock:(FeedBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kUserFeedService postData:parameters callBackBlock:^(id response, NSError *error) {
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    block(YES, [webResponse.result lastObject], error);
                    
                }
                else {
                    block(NO, nil, error);
                }
            }
            else {
                block(NO, nil, error);
            }
        }
        else {
            block(NO, nil, error);
        }
    }];
}
+ (void)getCurrentFeed:(NSDictionary *)params withSuccessBlock:(FeedBlock)block
{
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kUserCurrentFeedService postData:parameters callBackBlock:^(id response, NSError *error) {
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    block(YES, [webResponse.result lastObject], error);
                    
                }
                else {
                    block(NO, nil, error);
                }
            }
            else {
                block(NO, nil, error);
            }
        }
        else {
            block(NO, nil, error);
        }
    }];

}
+ (void)getPastFeed:(NSDictionary *)params withSuccessBlock:(FeedBlock)block
{
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kUserPastFeedService postData:parameters callBackBlock:^(id response, NSError *error) {
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    block(YES, [webResponse.result lastObject], error);
                    
                }
                else {
                    block(NO, nil, error);
                }
            }
            else {
                block(NO, nil, error);
            }
        }
        else {
            block(NO, nil, error);
        }
    }];

}



- (instancetype)initWithNotificationData:(NSDictionary *)params {
    self = [super init];
    
    if (self) {
        if([params objectNonNullForKey:kPageNumber])
            self.nextPage = numberValue([params objectForKey:kPageNumber]);
        if ([params objectNonNullForKey:kUserEvents]) {
            self.results = [[NSMutableArray alloc]init];
            NSArray *arrResult = [params objectForKey:kUserEvents];
            for (NSDictionary *dict in arrResult) {
                NotificationModel *event  = [[NotificationModel alloc]initWithNotificationData:dict];
                [self.results addObject:event];
            }
        }
    }
    return self;

}
+ (void)getNotifications:(NSDictionary *)params withSuccessBlock:(FeedBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kListNotificationService postData:parameters callBackBlock:^(id response, NSError *error) {
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    block(YES, [webResponse.result lastObject], error);
                    
                }
                else {
                    block(NO, nil, error);
                }
            }
            else {
                block(NO, nil, error);
            }
        }
        else {
            block(NO, nil, error);
        }
    }];
}
@end
