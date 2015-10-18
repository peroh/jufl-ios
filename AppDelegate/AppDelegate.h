//
//  AppDelegate.h
//  JUFL
//
//  Created by Ankur Arya on 07/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

extern AppDelegate *appDelegate;
@property (strong, nonatomic) UIWindow *window;

- (void)setRootForApp;

@end

