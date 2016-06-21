//
//  ApplicationConstantsHeader.h
//  MyScene
//
//  Created by Sashi Bhushan on 23/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#ifndef MyScene_SharedClass_h
#define MyScene_SharedClass_h

#define CheckForLocalNotificationAndReturn if(![AppPermissions checkForNotificationPermissionsOrReturn]) return;
#define CheckForLocalNotificationAndCheckOut [AppPermissions checkForNotificationPermissionsOrCheckOut];

#define NSStandardUserDefaults [NSUserDefaults standardUserDefaults]
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define CURRENT_USER_PIN @"UserPin"

//********************** Keys *************************

#define kPushAlert @"alert"
#define kUserDefaultRadiusKey @"Radius"
#define kAppFilterGenderKey @"interested_in"
#define kAppFilterRelationshipKey @"relationship_status"


//********************** Values *************************
#define kAlertNotificationType @"Alert"
#define kCheckOutNotificationType @"CheckOut"
#define kAlertOK @"OK"
#define kAlertCheckIn @"Check IN"
#define kAlertSettings @"Settings"
#define kAlertView @"View"
#define kAppFilterGenderValue [NSNumber numberWithInteger:[MySceneSingleton sharedInstance].filterGender]
#define kAppFilterRelationshipValue [NSNumber numberWithInteger:[MySceneSingleton sharedInstance].filterRelationship]


//********************** Messages *************************
#define kCheckOutWarningMessage @"Your check in is expiring in 10 mins"
#define kCheckOutMessage @"Your checkIn expired"
#define KSuccessfullyInviteSent @"Invitation Sent"
#define kLocalNotificationSettings @"Application requires notification Clicking OK will checkout if notifications not enabled"
#define kAlreadyFriendClickMessage @"Do you want to chat?"
#define kInvitationFirstMessage @"Write your message here..."
#define kWordLimitMessage @"Word limit is 150 characters"
#define kPasswordChangeSuccess @"Password changed successfully"

//********************** Notifications *************************
#define kFriendRequestNotification @"FriendRequestNotification"
#define kMessagetNotification @"MessagetNotification"

//********************** Flurry *************************
// Event Names
#define kFlurryBarTimeEvent @"BarTime"
#define kFlurryBarDrinkEvent @"BarDrink"
#define kFlurryAppUsageTimeEvent @"PeakUsageTime"
#define kFlurryAppUsageEvent @"AppUsageTrends"
#define kFlurryAppCheckInEvent @"AppCheckIn's"
#define kFlurryAppReplyEvent @"AppReplies"

// Eventy Keys
#define kFlurryDrinkNameKey @"DrinkName"
#define kFlurryDrinkTimeKey @"DrinkTime"
#define kFlurryGenderKey @"Gender"
#define kFlurryAgeKey @"Age"
#define kFlurryLocationKey @"Location"
#define kFlurryCheckInTimeKey @"CheckInTime"
#define kFlurryCheckInDurationKey @"CheckInDuration"
#define kFlurryReplyTimeKey @"ReplyTime"
#define kFlurryReplyReceivedDrinkKey @"DrinkReceived"
#define kFlurryReplySentDrinkKey @"DrinkSent"

#endif
