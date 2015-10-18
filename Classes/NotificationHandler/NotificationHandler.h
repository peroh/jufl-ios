//
//  NotificationHandler.h
//  MyScene
//
//  Created by Sashi Bhushan on 23/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationHandler : NSObject 

+(void)registerForLocalNotificationsInApp:(UIApplication *)application;

//+(void)scheduleAlertNotification:(NSInteger)checkInTime;
//+(void)scheduleCheckOutNotification:(NSInteger)checkInTime;
+(void)scheduleLocalNotification:(NSDate *)firedDate;
+(void)scheduleExpirationLocalNotification:(NSDate *)firedDate;

// Local Notification
+(void)handleLocalNotification:(UILocalNotification *)notification;
+(void)handleNotificationForAppLaunchWithLaunchOptions:(NSDictionary *)launchOptions;

// Push Notification
+(void)handlePushNotification:(NSDictionary *)userInfo isFromLaunch:(BOOL)fromLaunch;

@end
