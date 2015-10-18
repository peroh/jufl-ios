//
//  NotificationModel.h
//  JUFL
//
//  Created by Ankur on 11/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationModel : NSObject

@property (nonatomic, strong) EventModel *event;
@property (nonatomic, strong) NSString *messageString;
@property (nonatomic, strong) NSDate *notificationTime;
@property (nonatomic, assign) ListNotificationType notificationType;

- (instancetype)initWithNotificationData:(NSDictionary *)dataDic;

@end
