//
//  AppPermissions.h
//  MyScene
//
//  Created by Sashi Bhushan on 27/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPermissions : NSObject

+(void)checkForNotificationPermissionsOrCheckOut;
+(BOOL)checkForNotificationPermissionsOrReturn;

@end
