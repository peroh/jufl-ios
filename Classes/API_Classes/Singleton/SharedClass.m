//
//  MySceneSingleton.m
//  MyScene
//
//  Created by Vikash on 28/01/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import "SharedClass.h"

#import "Location.h"
#import "AppDelegate.h"


@implementation SharedClass


+ (SharedClass *)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        if(sharedInstance)
        {
            [(SharedClass *)sharedInstance setDeviceId:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            ((SharedClass *)sharedInstance).currentEvent = [[EventModel alloc]init];
        }
    });
    return sharedInstance;
}



- (void)requestForAppUsersWithContactArray:(NSArray *)contactArray
{

}


+ (UINavigationController *)getAppNavigationController
{
    id navController = appDelegate.window.rootViewController;
    if([navController isKindOfClass:[UINavigationController class]])
    {
        return navController;
    }
    else if([navController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)navController;
        navController = tabBarController.selectedViewController;
    }
    else
        DLog(@"navcontroller not found");
    
    return navController;
}
@end


