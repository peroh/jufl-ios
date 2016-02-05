//
//  WebServiceHeader.h
//  MyScene
//
//  Created by Naveen Rana on 11/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#ifndef MyScene_ApplicationConstantsHeader_h
#define MyScene_ApplicationConstantsHeader_h



#define CheckForLocalNotificationAndReturn if(![AppPermissions checkForNotificationPermissionsOrReturn]) return;
#define CheckForLocalNotificationAndCheckOut [AppPermissions checkForNotificationPermissionsOrCheckOut];

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define CURRENT_USER_PIN @"UserPin"

//********************** Keys *************************
#define kNotificationType @"NotificationType"
#define kWarningNotificationType @"Warning"
#define kExpireNotificationType @"Expire"
#define kPushAlert @"alert"
#define kUserDefaultRadiusKey @"Radius"
#define kAppFilterGenderKey @"interested_in"
#define kAppFilterRelationshipKey @"relationship_status"

// User Defaults
#define kCurrentUserID @"currentUserID"
#define kLoginTime @"loginTime"
#define kUserPrivacyPolicy @"PrivacyPolicy"
#define kUserTermsPolicy @"TermPolicy"

//********************** Values *************************
#define kAlertNotificationType @"Alert"
#define kCheckOutNotificationType @"CheckOut"
#define kAlertOK @"OK"
#define kAlertCheckIn @"Check IN"
#define kAlertSettings @"Settings"
#define kAlertView @"View"


//********************** Messages *************************
#define kMobileNumberErrorMessage @"Phone number must be numeric (7-14 Numbers)"
#define kInvalidOTPEnteredMessage @"Invalid OTP"
#define kReferralCodeErrorMessage @"Referral Code must be alphanumeric (6 characters)"

#define kLocalNotificationSettings @"Application requires notification Clicking OK will checkout if notifications not enabled"

//********************** Notifications *************************
#define kPinVerificationSuccessNotification @"PinVerificationSuccessNotification"

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


//File Handler
#define kImageFolder            @"Images"

//Application
#define kTitle     @"JUFL"

//In App Purchase
#define kIAPSuccessfullyPurchased       @"Purchase successfully"
#define kIAPFailed      @"Something went wrong . Please try later !"
#define kSubscriptionExpire @"Your Subscription Expired"
#define kSubscriptionAboutToExpire @"Your Subscription is About To Expire"

#define kSubscription      @"Subscription"
#define KRemoveTopViewFromStack     @"removeTopViewFromStack"
#define kTransactionIdentifier    @"transactionIdentifier"
#define kPrice    @"price"
#define KSinglePack @"single"
#define KFamilyPack @"family"
#define KFamilyMember @"Select Family Members"
#define kSubscriptionPurchasedSuccessfully   @"Subscription Purchased Successfully"

//Web service parameters
#define kError      @"Error"
#define kMessage    @"Message"
#define kResult     @"Result"
#define kSuccess    @"Success"
#define kNoResultFound      @"No results found"
#define kSomethingWentWrong @"Something went wrong"

// for angular arc slider

#define Max_LEFT_SLIDER_ANGLE 125
#define Max_RIGHT_SLIDER_ANGLE 54

//Sharing
#define kFacebookUrl @"FacebookUrl"
#define kTwitterUrl @"TwitterUrl"
#define kTumblrUrl @"TumblrUrl"

#define kIsTumblrLink  @"IsTumblrLink"
#define kIsFacebookLink  @"IsFacebookLink"
#define kIsTwitterLink  @"IsTwitterLink"


//Messages
#define kUserAlreadyExists @"Email already registered"


//Current Latitude and Longitude
#define kCurrentLatitude            [NSString stringWithFormat:@"%f",[Location sharedInstance].userCurrentLocation.latitude]
#define kCurrentLongitude         [NSString stringWithFormat:@"%f",  [Location sharedInstance].userCurrentLocation.longitude]
#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

//Placeholder Image
#define kPlaceHolderPlaceImage [UIImage imageNamed:@"loading"]


#define kPlaceHolderUserSignUpImage  [UIImage imageNamed:@"profileImage"]
#define kPlaceHolderUserdefaultProfileIcon  [UIImage imageNamed:@"defaultProfileIcon.png"]

#define kPlaceHolderDrinkIcon  [UIImage imageNamed:@"beer"]
#define kPlaceHolderAdvertise  [UIImage imageNamed:@""]



//Color codes
#define kIconGreenColor     [UIColor colorWithRed:46.0f/255.0f green:204.0f/255.0f blue:113.0f/255.0 alpha:1.0f]

#define kGrayColor     [UIColor colorWithRed:107.0f/255.0f green:109.0f/255.0f blue:108.0f/255.0 alpha:1.0f]

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#define Rgb2UIColorWithAlpha(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

//paging
#define kTimeStamp @"TimeStamp"
#define kTrue @"True"
#define kFalse @"False"

//tutorial
#define kIsWatchTutorial @"IsWatchTutorial"

//KeyBoard frame
#define KEYBOARD_FRAME(view)         CGRectMake(0, view.frame.size.height-216, 320, 216)



//File path
#define kUserIdToFolderPath(useridto)    [FileHandler getPathForFolderPath:kChatFolder withFileName:useridto]
#define kCategoriesTableEntity               ((CategoriesTable *)[Fetchsavefromcoredata insertUpdatefromDatabaseforentity:@"CategoriesTable"])

#define DATE_FORMAT_USED @"yyyy'-'MM'-'dd' 'HH':'mm':'ss"


#define kBundleIdentifier @"com.Appster.MyScene"
#define kBundleCurrentVersion @"BundleCurrentVersion"

//DIRECTORIES
#define DOCUMENT_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define NULLVALUE(m)                    ((m == nil || [m length]==0) ? @"" : m)

#define kPleaseWait                     NSLocalizedString(@"please wait...", nil)
#define kPleaseCheckInternetConnection                     NSLocalizedString(@"Please check your internet connection", nil)
#define kPleaseTryAgain                     NSLocalizedString(@"pleasetryagain", nil)
#define ShowPleaseTryAgainAlert             [Utils showOKAlertWithTitle:kTitle message:kPleaseTryAgain];

#define kFaceBookError   @"Please check your facebook settings"

#define kUpdatingMessage                     NSLocalizedString(@"updating", nil)
#define kGoogleAPIKey @"AIzaSyByzyohDDKy56kRHBDlWF_sBAg8c-5FRlE"

#define kPinVerificationResult @"pinVerificationResult"



#define kImageTitle @"Select Image"
#define kSelectFromCamera @"Capture from camera"
#define kSelectFromImageGallery @"Select from gallery"

#define KErrorCameraPermission @"Please check camera permission"
#define KNoCameraFound @"No Camera found"

#define kMuteGroupConversation @"Mute group conversation"
#define kUnmuteGroupConversation @"Unmute group conversation"

#endif
