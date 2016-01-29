//
//  EventModel.m
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "EventModel.h"

@implementation EventModel

+ (void)createEventWithParams:(NSDictionary *)params withHandler:(EventModelBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kCreateEventService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    NSDictionary *eventDict = [webResponse.result lastObject];
                    EventModel *event = [[EventModel alloc]initWithEventData:eventDict];
                    
                    NSArray *eventArray = [NSArray arrayWithObjects:event, nil];
                    
                    block(YES, eventArray, error);
                    
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

+ (NSDictionary *)getDictionaryFromModel:(EventModel *)event addLocation:(BOOL)location {
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc]init];
    if (event.name) {
        [eventDict setObject:event.name forKey:kEventName];
    }
    if (event.additionalInfo) {
        [eventDict setObject:event.additionalInfo forKey:kEventAdditionalInfo];
    }
    if (event.startTime) {
        [eventDict setObject: [NSString stringWithFormat:@"%.0f", [event.startTime timeIntervalSince1970]] forKey:kEventStartTime];
    }
    if (event.endTime) {
        [eventDict setObject: [NSString stringWithFormat:@"%.0f", [event.endTime timeIntervalSince1970]] forKey:kEventEndTime];
    }
    if (event.location.locationId) {
        [eventDict setObject:event.location.locationId forKey:kLocationId];
    }
    if (location) {
        
        if (event.location.name) {
            NSString *eventLocationName = [[event.location.name componentsSeparatedByString:@". - "] lastObject];
            [eventDict setObject:eventLocationName forKey:kLocationName];
        }
        if (event.location.address) {
            [eventDict setObject:event.location.address  forKey:kLocationAddress];
        }
        if (event.location.coordinate.latitude) {
            [eventDict setObject:[NSString stringWithFormat:@"%f",event.location.coordinate.latitude]  forKey:kLocationLat];
        }
        if (event.location.coordinate.longitude) {
            [eventDict setObject:[NSString stringWithFormat:@"%f",event.location.coordinate.longitude]  forKey:kLocationLong];
        }
    }
    if (event.eventId) {
        [eventDict setObject:event.eventId forKey:kEventId];
    }
    return eventDict;
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

-(instancetype)initWithEventData:(NSDictionary *)dict {
    self = [super init];
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.creatorId = [self objectOrNilForKey:kCreatorId fromDictionary:dict];
        self.additionalInfo = [self objectOrNilForKey:kEventAdditionalInfo fromDictionary:dict];
        
        self.endTime = [NSDate dateWithTimeIntervalSince1970:[[self objectOrNilForKey:kEventEndTime fromDictionary:dict] doubleValue]];
        self.startTime = [NSDate dateWithTimeIntervalSince1970:[[self objectOrNilForKey:kEventStartTime fromDictionary:dict] doubleValue]];
        self.eventId = [self objectOrNilForKey:kId fromDictionary:dict];
        self.location = [[LocationModel alloc]initWithLocationData:[self objectOrNilForKey:kLocation fromDictionary:dict]];
        self.name = [self objectOrNilForKey:kEventName fromDictionary:dict];
        self.isDeleted = [[self objectOrNilForKey:kDeleted fromDictionary:dict]boolValue];
        self.eventRespose = [[self objectOrNilForKey:kDecide fromDictionary:dict]integerValue];
        self.creator = [[UserModel alloc]initWithDictionary:[self objectOrNilForKey:kUser fromDictionary:dict]];
        self.goingCount = stringValue([self objectOrNilForKey:kGoingCount fromDictionary:dict]);
        self.cancelReason = stringValue([self objectOrNilForKey:kReason fromDictionary:dict]);
        
        self.goingBadgeCount = [[self objectOrNilForKey:kGoingBagdeCount fromDictionary:dict] intValue];
        self.cantGoingBadgeCount = [[self objectOrNilForKey:kCantGoingBadgeCount fromDictionary:dict] intValue];
        
        
    }
    return self;
}

+ (void)getEventDetailWithParams :(NSDictionary *)params withCompletion:(EventSuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    
    [Connection callServiceWithName:kEventDetailService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    NSDictionary *eventDict = [webResponse.result lastObject];
                    EventModel *event = [[EventModel alloc]initWithEventData:eventDict];
                    block(YES, event, error);
                    
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
+ (void)sendEventResponseWithParams :(NSDictionary *)params withCompletion:(EventSuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kEventDecideService postData:parameters callBackBlock:^(id response, NSError *error) {
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            if(webResponse)
            {
                NSDictionary *eventDict = [webResponse.result lastObject];
                EventModel *event = [[EventModel alloc]initWithEventData:eventDict];
                block(YES, event, error);
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

+ (void)removeUserFromEventWithParameters:(NSDictionary *)params completion:(SuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kEventRemoveUserService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                NSDictionary *userDict = [webResponse.result lastObject];
                block(YES, userDict, error);
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

+ (void)addUsersToEventWithParameters:(NSDictionary *)params completion:(SuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kEventAddMoreService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                NSDictionary *userDict = [webResponse.result lastObject];
                block(YES, userDict, error);
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

+ (void)updateEventWithParameters:(NSDictionary *)params completion:(EventSuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kEditEventService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            if(webResponse)
            {
                NSDictionary *eventDict = [webResponse.result lastObject];
                EventModel *event = [[EventModel alloc]initWithEventData:eventDict];
                block(YES, event, error);
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

+ (void)cancelEventWithParameters:(NSDictionary *)params completion:(EventSuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kCancelEventService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            if(webResponse)
            {
                NSDictionary *eventDict = [webResponse.result lastObject];
                EventModel *event = [[EventModel alloc]initWithEventData:eventDict];
                block(YES, event, error);
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

+ (void)hideEventWithParameters:(NSDictionary *)params completion:(HideSuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kHideEventService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            if(webResponse)
            {
            block(YES, error);
            }
            else {
                block(NO, error);
            }
        }
        else {
            block(NO, error);
        }
    }];
    
}

+ (void)onOffNotification:(NSDictionary *)params completion:(HideSuccessBlock)block
{
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    //[Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kOnOffNotificationService postData:parameters callBackBlock:^(id response, NSError *error) {
      //  [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            if(webResponse)
            {
                block(YES, error);
            }
            else {
                block(NO, error);
            }
        }
        else {
            block(NO, error);
        }
    }];
    

}

+ (void)notificationDetail:(NotificationBlock)block
{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc]init];
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    //[Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kNotificationDetailService postData:parameters callBackBlock:^(id response, NSError *error) {
       // [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            if(webResponse)
            {
                NSDictionary *eventDict = [webResponse.result lastObject];
                block(YES, eventDict, error);
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
