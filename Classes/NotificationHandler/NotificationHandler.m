//
//  NotificationHandler.m
//  MyScene
//
//  Created by Sashi Bhushan on 23/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

//#define LocalNotificationExpiryTime 10
//#define CheckOutAlertTime 600

#import "NotificationHandler.h"
#import "Categories.h"
#import "AppDelegate.h"
#import "TSMessage.h"
#import "NotificationsViewController.h"
#import "AppDelegate.h"
#import "CustomNavigationViewController.h"
#import "AFSharedClient.h"
#import "EventDetailViewController.h"
#import "TabBarViewController.h"


@implementation NotificationHandler

+(void)scheduleLocalNotification:(NSDate *)firedDate
{
    
}

+(void)scheduleExpirationLocalNotification:(NSDate *)firedDate
{
    
}


+(void)handleLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    
}


+(void)handleNotificationForAppLaunchWithLaunchOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        
    }
    else
    {
        localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if(localNotif)
        {
            [[self class] handlePushNotification:(NSDictionary *)localNotif isFromLaunch:YES];
        }
        
    }
}

#pragma mark - Register For Notification

+(void)registerForLocalNotificationsInApp:(UIApplication *)application
{
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
}


#pragma mark - Push Notification
+(void)handlePushNotification:(NSDictionary *)userInfo isFromLaunch:(BOOL)fromLaunch
{
    if (![UserModel currentUser]) {
        return;
    }
    
    UIViewController *topView = (UIViewController *)appDelegate.window.rootViewController;
    UINavigationController *navController = nil;
    
    if ([topView isKindOfClass:[TabBarViewController class]]) {
        
        navController = (CustomNavigationViewController*)((TabBarViewController *)topView).selectedViewController;
        
    }
    else {
        navController = (UINavigationController *)appDelegate.window.rootViewController;
    }
    
    UIViewController *visibleViewController = [navController visibleViewController];
    
    
    if (userInfo[kAps]) {
        NSDictionary *aps = userInfo[kAps];
        DLog(@"payload = %@",aps);
        if (aps) {
            NSURL *userImageUrl = [NSURL URLWithString:[aps objectForKey:@"image"]];
            //            PushNotificationType pushTag = [numberValue(aps[kPushTag]) integerValue];
            NSNumber *eventId = numberValue(aps[kEventId]);
            
            if(fromLaunch){
                NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
                
                if(AppSharedClass.notificationCount)
                    AppSharedClass.notificationCount = [NSNumber numberWithInteger:AppSharedClass.notificationCount.integerValue+count].stringValue;
                else
                    AppSharedClass.notificationCount = [NSString stringWithFormat:@"%li",(long)count];
                
                //                [[visibleViewController.tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:AppSharedClass.notificationCount];
                
                if ([visibleViewController isKindOfClass:[EventDetailViewController class]]) {
                    
                    EventDetailViewController *eventDetailViewController = (EventDetailViewController *)visibleViewController;
                    
                    [eventDetailViewController getEventDetail:eventId];
                }
                else if ([visibleViewController isKindOfClass:[NotificationsViewController class]]) {
                    // reload notification list;
                    NotificationsViewController *notificationViewController = (NotificationsViewController *)visibleViewController;
                    [notificationViewController reloadViewForNewNotifications];
                    
                }
                else {
                    BOOL shouldPushVc = YES;
                    for (EventDetailViewController *vc in [navController viewControllers]) {
                        if ([vc isKindOfClass:[EventDetailViewController class]]) {
                            shouldPushVc = NO;
                            vc.eventId = eventId;
                            vc.hidesBottomBarWhenPushed = YES;
                            [navController popToViewController:vc animated:YES];
                            break;
                        }
                        
                    }
                    if (shouldPushVc) {
                        EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEventId:eventId];
                        eventDetailViewController.hidesBottomBarWhenPushed = YES;
                        [navController pushViewController:eventDetailViewController animated:NO];
                    }
                    
                }
            }
            else {
                [Utils vibrateDevice];
                
                /*
                 Increase count for Notification
                 */
                 int pushTag = [numberValue(aps[kPushTag]) intValue];
                if (pushTag==6) {
                    AppSharedClass.notificationCount = nil;
                }
                else{
                if(AppSharedClass.notificationCount)
                    AppSharedClass.notificationCount = [NSNumber numberWithInt:AppSharedClass.notificationCount.intValue+1].stringValue;
                else
                    AppSharedClass.notificationCount = @"1";
                }
                
                [[visibleViewController.tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:AppSharedClass.notificationCount];
                
                if ([visibleViewController isKindOfClass:[NotificationsViewController class]]) {
                    NotificationsViewController *notificationViewController = (NotificationsViewController *)visibleViewController;
                    [notificationViewController reloadViewForNewNotifications];
                }
                else {
                    [[SDWebImageManager sharedManager] downloadImageWithURL:userImageUrl options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        UIImage *userImage;
                        if(image)
                            userImage = image;
                        else
                            userImage = [UIImage imageNamed:@"contactPlaceholder"];
                        
                        
                        [TSMessage showNotificationInViewController:navController.visibleViewController title:[aps objectForKey:@"alert"] subtitle:nil image:userImage type:TSMessageNotificationTypeMessage duration:2 callback:^{
                            if ([visibleViewController isKindOfClass:[EventDetailViewController class]]) {
                                
                                EventDetailViewController *eventDetailViewController = (EventDetailViewController *)visibleViewController;
                                eventDetailViewController.hidesBottomBarWhenPushed = YES;
                                [eventDetailViewController getEventDetail:eventId];
                                //                                EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEventId:eventId];
                                //                                 eventDetailViewController.hidesBottomBarWhenPushed = YES;
                                //                                NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: navController.viewControllers];
                                //                                [navigationArray removeLastObject];  // You can pass your index here
                                //                                navController.viewControllers = navigationArray;
                                //
                                //                                [navController pushViewController:eventDetailViewController animated:NO];
                            }
                            else {
                                BOOL shouldPushVc = YES;
                                for (EventDetailViewController *vc in [navController viewControllers]) {
                                    if ([vc isKindOfClass:[EventDetailViewController class]]) {
                                        shouldPushVc = NO;
                                        vc.eventId = eventId;
                                        [navController popToViewController:vc animated:YES];
                                        break;
                                    }
                                    
                                }
                                if (shouldPushVc) {
                                    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEventId:eventId];
                                    eventDetailViewController.hidesBottomBarWhenPushed = YES;
                                    [navController pushViewController:eventDetailViewController animated:NO];
                                }
                                
                            }
                        } buttonTitle:nil buttonCallback:^{
                            
                            
                        } atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:NO];
                        
                    }];
                    
                }
            }
        }
    }
}

- (void)clearBadge {
    AppSharedClass.notificationCount = nil;
    TabBarViewController *tabBarController = (TabBarViewController *)appDelegate.window.rootViewController;
    [[tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:nil];
}
@end

