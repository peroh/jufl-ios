//
//  NotificationModel.m
//  JUFL
//
//  Created by Ankur on 11/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "NotificationModel.h"

@implementation NotificationModel

- (instancetype)initWithNotificationData:(NSDictionary *)dict {
    self = [super init];
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.event = [[EventModel alloc]initWithEventData:dict]
        ;
        self.messageString = [self objectOrNilForKey:kAlert fromDictionary:dict];
        self.notificationTime = [NSDate dateWithTimeIntervalSince1970:[[self objectOrNilForKey:@"time" fromDictionary:dict] doubleValue]];
        self.notificationType = [[self objectOrNilForKey:kType fromDictionary:dict]integerValue];
    }
    return self;
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
