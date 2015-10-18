//
//  AppDelegate.m
//  JUFL
//
//  Created by Ankur Arya on 07/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "AppDelegate.h"
#import "LandingViewController.h"
#import "CustomNavigationViewController.h"
#import "UserModel.h"
#import "ProfileViewController.h"
#import "TabBarViewController.h"
#import "Configuration.h"
#import "NotificationHandler.h"
#import "Mixpanel.h"
#import "FriendsViewController.h"

#define kMixpanelToken [Configuration getMixpanelToken]

@interface AppDelegate ()

@end

@implementation AppDelegate


AppDelegate *appDelegate = nil; //external variable

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    appDelegate= self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [Configuration serverName];
//    });
    
    [[Location sharedInstance]initLocationManager];
    
    
    [NotificationHandler registerForLocalNotificationsInApp:application];
    [NotificationHandler handleNotificationForAppLaunchWithLaunchOptions:launchOptions];
    
    [self setRootForApp];
    [self setBadge];
    if ([self.window.rootViewController isKindOfClass:[TabBarViewController class]]) {
        [Contacts sharedInstance];
    }
    
    [Mixpanel sharedInstanceWithToken:kMixpanelToken];
    
   
    [[Mixpanel sharedInstance] track:@"AppOpen"];
    
    if([UserDefaluts valueForKey:kCurrentUserID]) {
     [[Mixpanel sharedInstance] timeEvent:@"UserSession"];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if([UserDefaluts valueForKey:kCurrentUserID]) {
    [[Mixpanel sharedInstance] track:@"UserSession" properties:@{kUserID: [UserDefaluts valueForKey:kCurrentUserID]}];
    }
    [self clearBadge];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if([UserDefaluts valueForKey:kCurrentUserID]) {
    [[Mixpanel sharedInstance] timeEvent:@"UserSession"];
    }
    [self setBadge];
    //    [self checkContactPermission];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if([UserDefaluts valueForKey:kCurrentUserID]) {
    [[Mixpanel sharedInstance] track:@"UserSession" properties:@{kUserID: [UserDefaluts valueForKey:kCurrentUserID]}];
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates
}


#pragma mark - Push - Notification

- (void)setBadge {
    NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    AppSharedClass.notificationCount = [NSString stringWithFormat:@"%li",(long)count];
    
    
    
    TabBarViewController *tabBarController = (TabBarViewController *)appDelegate.window.rootViewController;
    if ([tabBarController isKindOfClass:[TabBarViewController class]] && [AppSharedClass.notificationCount integerValue] > 0) {
        [[tabBarController.tabBar.items objectAtIndex:4] setBadgeValue:AppSharedClass.notificationCount];
    }
}
- (void)clearBadge {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *devToken = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([NRValidation isValidString:devToken]){
        [[SharedClass sharedInstance] setIsRegistered:YES];
        [[SharedClass sharedInstance] setDeviceToken:devToken];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(application.applicationState == UIApplicationStateActive)
        [NotificationHandler handlePushNotification:userInfo isFromLaunch:NO];
    else
        [NotificationHandler handlePushNotification:userInfo isFromLaunch:YES];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [[SharedClass sharedInstance] setIsRegistered:NO];
    DLog(@"Failed to get token, error: %@", error);
}

- (void)pushNotificationReceivedWithDictionary : (NSDictionary *)userInfo
{
    
}

#pragma mark MyFunctions
- (void)setRootForApp
{
    UIViewController *rootViewController = nil;
    if([UserDefaluts objectForKey:kCurrentUserID])
    {
        if ([UserModel currentUser].firstName) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            rootViewController = [[TabBarViewController alloc]init];
        }
        else {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            UserModel *currentUser = [[UserModel alloc]initWithUserTable:[UserModel currentUser]];
            ProfileViewController *profileViewController = [[ProfileViewController alloc]initWithUser:currentUser];
            rootViewController = [[CustomNavigationViewController alloc]initWithRootViewController:profileViewController];
        }
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        LandingViewController *landingViewController = [[LandingViewController alloc]initWithNibName:NSStringFromClass([LandingViewController class]) bundle:nil];
        rootViewController = [[CustomNavigationViewController alloc]initWithRootViewController:landingViewController];
    }
    
    [self showRootViewController:rootViewController];
}

- (void)showRootViewController :(UIViewController *)viewController {
    self.window = nil;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    
    [UIView transitionWithView:self.window
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.window.rootViewController = viewController;
                    }
                    completion:nil];
    
    [self.window makeKeyAndVisible];
}

@end
