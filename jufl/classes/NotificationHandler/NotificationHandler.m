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
#import "ChatViewController.h"


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
            int pushTag = [numberValue(aps[kPushTag]) intValue];
            NSURL *userImageUrl = [NSURL URLWithString:[aps objectForKey:@"image"]];
            NSNumber *eventId = numberValue(aps[kEventId]);
            
            if(fromLaunch){
                
                ///when app is in come from background to forground
                NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
                
                if(AppSharedClass.notificationCount)
                    AppSharedClass.notificationCount = [NSNumber numberWithInteger:AppSharedClass.notificationCount.integerValue+count].stringValue;
                else
                    AppSharedClass.notificationCount = [NSString stringWithFormat:@"%li",(long)count];
                
                if (pushTag == kPushChatTag) {//to check chat notification
                    DLog(@"******aaaaaaaaaaaa********");

                    [UserDefaluts setObject:[aps objectForKey:kChatTypeStatus] forKey:kChatType];
                    [UserDefaluts setObject:[aps objectForKey:kSenderId] forKey:kLastSenderId];
                    [UserDefaluts setObject:[aps objectForKey:kChatSenderName] forKey:kLastSenderName];
                    
                    
                    NSString *eventName = [aps objectForKey:kChatEventName];
                    NSString *chatUserName = [aps objectForKey:kChatSenderName];
                    NSString *chatType = [UserDefaluts objectForKey:kChatType];

                    
                    
                     if ([visibleViewController isKindOfClass:[ChatViewController class]]) {
                         DLog(@"*******12222222********");
                        
                        ChatViewController *chatViewController = (ChatViewController *)visibleViewController;
                        if ([chatType isEqualToString:kGroupChat]) {
                            
                            [chatViewController eventWithNotifiChatEventId:eventId chatUserName:chatUserName eventName:eventName withViewMode:ChatModeGroup];
                        }
                        else if ([chatType isEqualToString:kPrivateChat])
                        {
                            [chatViewController eventWithNotifiChatEventId:eventId chatUserName:chatUserName eventName:eventName withViewMode:ChatModeSingle];
                        }
                        else{
                            [chatViewController eventWithNotifiChatEventId:eventId chatUserName:chatUserName eventName:eventName withViewMode:ChatModeGroup];
                        }
                       
                    }
                    else {
                        BOOL shouldPushVc = YES;
                        for (ChatViewController *vc in [navController viewControllers]) {
                            if ([vc isKindOfClass:[ChatViewController class]]) {
                                shouldPushVc = NO;
                                vc.hidesBottomBarWhenPushed = YES;
                                [navController popToViewController:vc animated:NO];
                                break;
                            }
                        }
                        if (shouldPushVc) {
                            DLog(@"*******33333333********");
                            
                            ChatViewController *chatViewController = nil;
                            if ([chatType isEqualToString:kGroupChat]) {
                                chatViewController = [[ChatViewController alloc] initWithNtotiChatEventId:eventId eventName:eventName chatUserName:chatUserName withViewMode:ChatModeGroup];
                            }
                            else if ([chatType isEqualToString:kPrivateChat])
                            {
                                chatViewController = [[ChatViewController alloc] initWithNtotiChatEventId:eventId eventName:eventName chatUserName:chatUserName withViewMode:ChatModeSingle];
                                
                            }
                            else{
                                chatViewController = [[ChatViewController alloc] initWithNtotiChatEventId:eventId eventName:eventName chatUserName:chatUserName withViewMode:ChatModeGroup];
                                
                            }
                            chatViewController.hidesBottomBarWhenPushed = YES;
                            [navController pushViewController:chatViewController animated:NO];
                        }
                        
                    }
                    
                }
                else if (pushTag == kPushVersionTag) //For new version
                {
                     DLog(@"******new version1111********");
                //do nothing
                }
                else{
                    DLog(@"******bbbbbbbbbbbb********");
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
                            //Remove last chat record
                            [UserDefaluts removeObjectForKey:kChatType];
                            [UserDefaluts removeObjectForKey:kLastSenderId];
                            [UserDefaluts removeObjectForKey:kLastSenderName];
                            EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]initWithEventId:eventId];
                            eventDetailViewController.hidesBottomBarWhenPushed = YES;
                            [navController pushViewController:eventDetailViewController animated:NO];
                        }
                        
                    }
                }
                
             
            }
            else {
                ///when app is in forground
                [Utils vibrateDevice];
                [Utils playAlertSound];
                
                /*
                 Increase count for Notification
                 */
                if (pushTag==6) {
                    AppSharedClass.notificationCount = nil;
                }
                else{
                    if(AppSharedClass.notificationCount)
                    {
                        if (pushTag == kPushChatTag)
                        {
                            //do nothing
                        }
                        else{
                            AppSharedClass.notificationCount = [NSNumber numberWithInt:AppSharedClass.notificationCount.intValue+1].stringValue;
                        }
                    }
                    else
                    {
                        if (pushTag == kPushChatTag)
                        {
                           //do nothing
                        }
                        else
                        {
                          AppSharedClass.notificationCount = @"1";
                        }
                    }
                }
                
                if([AppSharedClass.notificationCount integerValue]>0)
                {
                   [[visibleViewController.tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:AppSharedClass.notificationCount];
                }
                else{
                    AppSharedClass.notificationCount = nil;
                    [[visibleViewController.tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:nil];
                }
                
                
                if (pushTag == kPushChatTag) {//to check chat notification
                    
                    [UserDefaluts setObject:[aps objectForKey:kChatTypeStatus] forKey:kChatType];
                    [UserDefaluts setObject:[aps objectForKey:kSenderId] forKey:kLastSenderId];
                    [UserDefaluts setObject:[aps objectForKey:kChatSenderName] forKey:kLastSenderName];
                    
                    
//                    NSString *eventName = [aps objectForKey:kChatEventName];
//                    NSString *chatUserName = [aps objectForKey:kChatSenderName];
//                    NSString *chatType = [UserDefaluts objectForKey:kChatType];

                     DLog(@"******aaaaaaaaaaaa111111********");
                   
                        [[SDWebImageManager sharedManager] downloadImageWithURL:userImageUrl options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            
                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            UIImage *userImage;
                            if(image)
                                userImage = image;
                            else
                                userImage = [UIImage imageNamed:@"contactPlaceholder"];
                            
//                            [TSMessage showNotificationInViewController:navController.visibleViewController title:[aps objectForKey:@"alert"] subtitle:nil image:userImage type:TSMessageNotificationTypeMessage duration:2 callback:^{
//
                                if ([visibleViewController isKindOfClass:[ChatViewController class]]) {
                                   
                                    DLog(@"*******55555555********");
                                    
                                     /*
                                    ChatViewController *chatViewController = (ChatViewController *)visibleViewController;
                                    if ([chatType isEqualToString:kGroupChat]) {
                                        [chatViewController eventWithNotifiChatEventId:eventId chatUserName:chatUserName eventName:eventName withViewMode:ChatModeGroup];
                                    }
                                    else if ([chatType isEqualToString:kPrivateChat])
                                    {
                                        [chatViewController eventWithNotifiChatEventId:eventId chatUserName:chatUserName eventName:eventName withViewMode:ChatModeSingle];
                                    }
                                    else{
                                        [chatViewController eventWithNotifiChatEventId:eventId chatUserName:chatUserName eventName:eventName withViewMode:ChatModeGroup];
                                    }
                                     */
                                    
                                   
                                }
                                else {
                                    BOOL shouldPushVc = YES;
                                    for (ChatViewController *vc in [navController viewControllers]) {
                                        if ([vc isKindOfClass:[ChatViewController class]]) {
                                            shouldPushVc = NO;
                                            vc.hidesBottomBarWhenPushed = YES;
                                            [navController popToViewController:vc animated:NO];
                                            break;
                                        }
                                    }
                                    if (shouldPushVc) {
                                        DLog(@"*******66666666********");
                                        [TSMessage showNotificationInViewController:navController.visibleViewController title:[aps objectForKey:@"alert"] subtitle:nil image:userImage type:TSMessageNotificationTypeMessage duration:2 callback:^{
                                            
                                        } buttonTitle:nil buttonCallback:^{
                                            
                                        } atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:NO];
                                        
                                        /*
                                        ChatViewController *chatViewController = nil;
                                        if ([chatType isEqualToString:kGroupChat]) {
                                             chatViewController = [[ChatViewController alloc] initWithNtotiChatEventId:eventId eventName:eventName chatUserName:chatUserName withViewMode:ChatModeGroup];
                                        }
                                        else if ([chatType isEqualToString:kPrivateChat])
                                        {
                                             chatViewController = [[ChatViewController alloc] initWithNtotiChatEventId:eventId eventName:eventName chatUserName:chatUserName withViewMode:ChatModeSingle];
                                        }
                                        else{
                                            chatViewController = [[ChatViewController alloc] initWithNtotiChatEventId:eventId eventName:eventName chatUserName:chatUserName withViewMode:ChatModeGroup];
                                            
                                        }
                                        chatViewController.hidesBottomBarWhenPushed = YES;
                                        [navController pushViewController:chatViewController animated:NO];
                                         */
                                    }
                                    
                                }
                           // } buttonTitle:nil buttonCallback:^{
                            
                            //} atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:NO];
                            
                        }];
                        
                    
                }
                else if (pushTag == kPushVersionTag) //For new version
                {
                    
                    DLog(@"******new version222222********");
                    [TSMessage showNotificationInViewController:navController.visibleViewController title:[aps objectForKey:@"alert"] subtitle:nil image:nil type:TSMessageNotificationTypeMessage duration:2 callback:^{
                        
                    } buttonTitle:nil buttonCallback:^{

                    } atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:NO];
                }
                else
                {
                    DLog(@"******bbbbbbbbbbb111111********");
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
                                        //Remove last chat record
                                        [UserDefaluts removeObjectForKey:kChatType];
                                        [UserDefaluts removeObjectForKey:kLastSenderId];
                                        [UserDefaluts removeObjectForKey:kLastSenderName];
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
}

- (void)clearBadge {
    AppSharedClass.notificationCount = nil;
    TabBarViewController *tabBarController = (TabBarViewController *)appDelegate.window.rootViewController;
    [[tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:nil];
}
@end

