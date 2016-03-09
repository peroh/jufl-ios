//
//  ApplicationConstantsHeader.h
//  MyScene
//
//  Created by Sashi Bhushan on 23/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#ifndef MyScene_WebServiceHeader_h
#define MyScene_WebServiceHeader_h

//Web service names

#define kSendOTPService @"send-otp"
#define kProfileService @"profile"
#define kParseContactsService @"parse-contacts"
#define kCreateEventService @"create-event"
#define kUserFeedService @"user-feed"
#define kUserCurrentFeedService @"profile-current-event-detail"
#define kUserPastFeedService @"profile-past-event-detail"
#define kFriendBlockService @"friend-block-unblock"
#define kFlagImageService @"flag-user-image"
#define kParticipantListService @"participant-list"
#define kEventDecideService @"event-decide-status"
#define kEventDetailService @"event-detail"
#define kEventAddMoreService @"event-add-invite"
#define kEventRemoveUserService @"event-invite-remove"
#define kEditEventService @"edit-event"
#define kHideEventService @"event-hide"
#define kOnOffNotificationService @"notification-setting"
#define kNotificationDetailService @"notification-setting-status"
#define kCancelEventService @"event-cancel"
#define kSignOutService @"sign-out"
#define kListNotificationService @"list-notification"
#define KTermsPolicy @"term-policy"
#define KPrivacyPolicy @"privacy-policy"

//Chat services
#define kGetGroupChatService @"get-group-chat"
#define kGetPrivateChatService @"get-private-chat"
#define kGetEventNotification @"event-notification-setting"

#define kGetLatestPrivateChatService @"get-refresh-private-chat"
#define kGetLatestGroupChatService @"get-refresh-public-chat"

#define kPostGroupChatService @"group-chat"
#define kPostPrivateChatService @"private-chat"

#define kChatListService @"event-member-list"



//Web service keys
#define kCountryCode @"country_code"
#define kDeviceToken @"device_token"
#define kDeviceId @"device_id"
#define kEventId @"event_id"
#define kFirstName @"first_name"
#define kLastName @"last_name"
#define kMobileNumber @"mobile_no"
#define kImage @"image"
#define kContactsArray @"contacts"
#define kEventName @"name"
#define kDeleted @"deleted"
#define kDecide @"decide"
#define kEventAdditionalInfo @"description"
#define kEventStartTime @"start_time"
#define kEventEndTime @"end_time"
#define kLocationId @"location_id"
#define kLocationName @"location_name"
#define kLocationAddress @"address"
#define kLocationLat @"latitude"
#define kLocationLong @"longitude"
#define kInvitedIds @"invited_id"
#define kCreatorId @"creator_id"
#define kId @"id"
#define kLocation @"location"
#define kPageNumber @"page"
#define kUserEvents @"user events"
#define kUser @"user"
#define kFriendId @"friend_id"
#define kType @"type"
#define kEventId @"event_id"
#define kNotificationInvite @"event_invite"
#define kNotificationEdit @"event_edit"
#define kNotificationCancel @"event_cancel"

//dhirendra cahnge
#define kParticipantList @"participant list"
#define kBadgeCount @"badgeCount"
#define kChatImagePath @"path"
#define kDateTime @"date_time"
#define kReceiptId @"receipt_id" //to user id
#define kSenderId @"sender_id" //selected member from private list user id
#define kLastMsgId @"last_msg_id"
#define kLatestMsgId @"last_msg_id"
#define kChatMessage @"message"
#define kChatInfo @"chatInfo"
#define kUserInfo @"userInfo"
#define kBadgeCount @"badgeCount"
#define kGroupUnreadMsgCount @"groupBadgeCount"
#define kPrivateUnreadMsgCount @"privateBadgeCount"


#define kNotificationInviteeNotiication @"event_status_update"
#define kNotificationActivityScheduled @"event_reminder_status"
#define kNotificationChat @"chat_notification"
#define kNotificationEvent @"event_notification"

/////////

#define kGoingCount @"going_count"

#define kGoingBagdeCount @"badge_going_count"
#define kCantGoingBadgeCount @"badgecantgo_count"

#define kTabGoing  @"going"
#define kShowing @"showing"

#define kReason @"reason"
#define kAlert @"alert"

#define kAps @"aps"
#define kPushTag @"push_tag"



//.........................................Four Square/..................................
#define kFourSquareVenueExploreUrl @"venues/explore"

#define kFSAutocomplete @"venues/suggestcompletion"

#define kFSSearchVenue @"venues/search"


#define kFourSquareKey @"ZD0MG40ZX5O0EORAC0NQVNGUSB5WWMLCXNGYNP0TIZ0YSVH0"
#define kFourSquareVersion @"v"
#define kFourSquareOAuth @"oauth_token"

#define kFourSquareVenuePhotos @"venuePhotos"

#define kFourSquareClientID @"ZD0MG40ZX5O0EORAC0NQVNGUSB5WWMLCXNGYNP0TIZ0YSVH0"
#define kFourSquareClientSecret @"B5XUU1EBNB00RIIT2XUEXIHH0WFU50YYIEJPQ2DZOGP2MFWY"

#define kFourSquareVersionIdentifier @"20150714"
#define kFourSquareLatLong [NSString stringWithFormat:@"%f,%f",[Location sharedInstance].userCurrentLocation.latitude,[Location sharedInstance].userCurrentLocation.longitude]
#define KRadiusKey @"radius"
#define kRadius @"2000"
#define kDefaultRadius @"2000"
#define KAllowedRadiusForCheckIn @"1000"


//.........................................Web Services/..................................


//UserResponse
#define kUserID @"user_id"

#define kInternetConectionError         @"Please check your internet connection & try again"

#endif
