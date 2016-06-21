//
//  AppPermissions.m
//  MyScene
//
//  Created by Sashi Bhushan on 27/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import "AppPermissions.h"

@implementation AppPermissions

+(void)checkForNotificationPermissionsOrCheckOut
{
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types & UIUserNotificationTypeAlert) {
    }
    else
    {
        [[Utils sharedInstance] openAlertViewWithTitle:kTitle message:kLocalNotificationSettings buttons:@[kAlertSettings,kAlertOK] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
            if(buttonIndex == 0)
            {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
            else
            {
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            }
        }];
    }
}

+(BOOL)checkForNotificationPermissionsOrReturn
{
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types & UIUserNotificationTypeAlert) {
        return YES;
    }
    else
    {
        [[Utils sharedInstance] openAlertViewWithTitle:kTitle message:kLocalNotificationSettings buttons:@[kAlertSettings,kAlertOK] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
            if(buttonIndex == 0)
            {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
            else
            {
            }
        }];
        
        return NO;
    }
}

@end
