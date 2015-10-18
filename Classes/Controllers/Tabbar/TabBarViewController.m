//
//  TabBarViewController.m
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "TabBarViewController.h"
#import "FeedViewController.h"
#import "FriendsViewController.h"
#import "CreateEventViewController.h"
#import "MyProfileViewController.h"
#import "NotificationsViewController.h"
#import "CustomNavigationViewController.h"
#import "AppDelegate.h"

@interface TabBarViewController ()<UITabBarControllerDelegate>

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    FeedViewController *feedViewController = [[FeedViewController alloc]initWithNibName:NSStringFromClass([FeedViewController class]) bundle:nil];
    CustomNavigationViewController *feedNavigationController = [[CustomNavigationViewController alloc]initWithRootViewController:feedViewController];
    feedNavigationController.viewTag = 0;
    
    feedViewController.tabBarItem.image = [[UIImage imageNamed:@"events"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    feedViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"eventsActive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [feedViewController.tabBarItem setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    
    FriendsViewController *friendsViewController = [[FriendsViewController alloc]initWithViewMode:FriendViewModeShowUsers];
    
    CustomNavigationViewController *friendsNavigationController = [[CustomNavigationViewController alloc]initWithRootViewController:friendsViewController];
    friendsNavigationController.viewTag = 1;
    
    friendsViewController.tabBarItem.image = [[UIImage imageNamed:@"friends"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    friendsViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"friendsActive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [friendsViewController.tabBarItem setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    
    CreateEventViewController *createEventViewController = [[CreateEventViewController alloc]initWithEvent:nil withViewMode:EventViewModeCreate];
    
    CustomNavigationViewController *createEventNavigationController = [[CustomNavigationViewController alloc]initWithRootViewController:createEventViewController];
    createEventNavigationController.viewTag = 2;
    
    createEventViewController.tabBarItem.image = [[UIImage imageNamed:@"create"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    createEventViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"createActive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [createEventViewController.tabBarItem setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    
    MyProfileViewController *myProfileViewController = [[MyProfileViewController alloc]initWithNibName:NSStringFromClass([MyProfileViewController class]) bundle:nil];
    
    CustomNavigationViewController *myProfileNavigationController = [[CustomNavigationViewController alloc]initWithRootViewController:myProfileViewController];
    myProfileNavigationController.viewTag = 3;
    
    myProfileViewController.tabBarItem.image = [[UIImage imageNamed:@"profile"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    myProfileViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"profileActive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [myProfileViewController.tabBarItem setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
   
    NotificationsViewController *notificationsViewController = [[NotificationsViewController alloc]initWithNibName:NSStringFromClass([NotificationsViewController class]) bundle:nil];
    
    CustomNavigationViewController *notificationNavigationController = [[CustomNavigationViewController alloc]initWithRootViewController:notificationsViewController];
    notificationNavigationController.viewTag = 4;
    
    notificationsViewController.tabBarItem.image = [[UIImage imageNamed:@"notification"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    notificationsViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"notificationActive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [notificationsViewController.tabBarItem setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    self.viewControllers = @[feedNavigationController, friendsNavigationController, createEventNavigationController, myProfileNavigationController, notificationNavigationController];
    UIColor* offWhite = Rgb2UIColorWithAlpha(245, 245, 245, 0.8);
    
    [self.tabBar setBackgroundImage:[self imageWithColor:[UIColor whiteColor]]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    self.tabBar.layer.borderWidth = 0.50;
    self.tabBar.layer.borderColor = offWhite.CGColor;
    self.delegate = self;
    [[UITabBar appearance] setTintColor:offWhite];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)showNotifications {
    NotificationsViewController *notificationsViewController = [[NotificationsViewController alloc]initWithNibName:NSStringFromClass([NotificationsViewController class]) bundle:nil];
    notificationsViewController.view.backgroundColor = [UIColor clearColor];
    CustomNavigationViewController *notificationNavigationController = [[CustomNavigationViewController alloc]initWithRootViewController:notificationsViewController];

    notificationNavigationController.view.backgroundColor  = [UIColor clearColor];
    notificationNavigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:notificationNavigationController animated:YES completion:^{
        
    }];
//    [appDelegate.window addSubview:[[SharedClass sharedInstance] showNotificationsView]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    CustomNavigationViewController *navigationController = (CustomNavigationViewController *)viewController;
    if (navigationController.viewTag != 0) {
        AppSharedClass.lastSelectedIndex = navigationController.viewTag;
    }
    
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    CustomNavigationViewController *navigationController = (CustomNavigationViewController *)viewController;
    
    if (navigationController.viewTag == 4) {
        [self showNotifications];
        return NO;
    }
    return YES;
}
@end
