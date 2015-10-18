//
//
//
//
//  Created by Vikash on 28/01/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NotificationsViewController.h"

@interface SharedClass : NSObject


@property (strong, nonatomic) NSString *deviceId;

@property (nonatomic) BOOL gotItImageCrop;
@property (nonatomic, strong) EventModel *currentEvent;

+ (SharedClass *)sharedInstance;
+ (UINavigationController *)getAppNavigationController;

// Push Variables
@property (assign,nonatomic)  BOOL isRegistered;
@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *notificationCount;
//
@property (assign, nonatomic) NSInteger lastSelectedIndex;

@end
