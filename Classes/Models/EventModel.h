//
//  EventModel.h
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LocationModel, EventModel;

typedef void (^EventModelBlock)(BOOL success, NSArray *events, NSError *error);
typedef void (^EventSuccessBlock)(BOOL success, EventModel *event, NSError *error);
typedef void (^HideSuccessBlock)(BOOL success,NSError *error);
typedef void (^NotificationBlock)(BOOL success, NSDictionary *notificationDic, NSError *error);

@interface EventModel : NSObject

@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *additionalInfo;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSNumber *creatorId;
@property (nonatomic, assign) EventResponse eventRespose;
@property (nonatomic, assign) BOOL isDeleted;
@property (nonatomic, strong) LocationModel *location;
@property (nonatomic, strong) UserModel *creator;
@property (nonatomic, strong) NSString *goingCount;
@property (nonatomic, strong) NSString *cancelReason;

@property (nonatomic, assign) int goingBadgeCount;
@property (nonatomic, assign) int cantGoingBadgeCount;

+ (void)createEventWithParams:(NSDictionary *)params withHandler:(EventModelBlock)block;

+ (NSDictionary *)getDictionaryFromModel:(EventModel *)event addLocation:(BOOL)location;

- (instancetype)initWithEventData:(NSDictionary *)dataDic;

+ (void)getEventDetailWithParams :(NSDictionary *)params withCompletion:(EventSuccessBlock)block;

+ (void)sendEventResponseWithParams :(NSDictionary *)params withCompletion:(EventSuccessBlock)block;

+ (void)removeUserFromEventWithParameters:(NSDictionary *)params completion:(SuccessBlock)block;

+ (void)addUsersToEventWithParameters:(NSDictionary *)params completion:(SuccessBlock)block;

+ (void)updateEventWithParameters:(NSDictionary *)params completion:(EventSuccessBlock)block;

+ (void)cancelEventWithParameters:(NSDictionary *)params completion:(EventSuccessBlock)block;

+ (void)hideEventWithParameters:(NSDictionary *)params completion:(HideSuccessBlock)block;

+ (void)onOffNotification:(NSDictionary *)params completion:(HideSuccessBlock)block;

+ (void)notificationDetail:(NotificationBlock)block;

@end
