//
//  EnumHeader.h
//  MiVista
//
//  Created by Ankur Arya on 13/05/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#ifndef MiVista_EnumHeader_h
#define MiVista_EnumHeader_h


typedef NS_ENUM(NSUInteger, PushNotificationType) {
    PushNotificationTypeInvite = 1,
    PushNotificationTypeEdit,
    PushNotificationTypeCancel
};

typedef NS_ENUM(NSUInteger, FriendViewMode) {
    FriendViewModeShowUsers = 0,
    FriendViewModeInviteUsers,
    FriendViewModeInviteMore
};

typedef NS_ENUM(NSUInteger, FriendTableViewMode) {
    FriendTableViewModeAppUser = 0,
    FriendTableViewModeNonUser
};

typedef NS_ENUM(NSUInteger, EventResponse) {
    EventResponseAccepted = 0,
    EventResponseRejected,
    EventResponseNoResponse
};

typedef NS_ENUM(NSUInteger, FeedTableViewMode) {
    FeedTableViewModeAll = 0,
    FeedTableViewModeGoing
};

typedef NS_ENUM(NSUInteger, CurrentPastFeedTableViewMode) {
    CurrentPastFeedTableViewModeCurrent = 0,
    CurrentPastFeedTableViewModePast
};

typedef NS_ENUM(NSUInteger, TermsPolicyMode) {
    TermsMode = 0,
    PolicyMode
};

typedef NS_ENUM(NSUInteger, EventDetailMode) {
    EventDetailModeMyEvent = 0,
    EventDetailModeAcceptedEvent,
    EventDetailModeNotAcceptedEvent,
    EventDetailModeRejected,
    EventDetailModeNewEvent
};

typedef NS_ENUM(NSUInteger, GoingViewMode) {
    GoingViewModeCreator = 0,
    GoingViewModeInvitee
};

typedef NS_ENUM(NSUInteger, GoingTableViewMode) {
    GoingTableViewModeInvited = 0,
    GoingTableViewModeGoing
};

typedef NS_ENUM(NSUInteger, EventViewMode) {
    EventViewModeCreate = 0,
    EventViewModeEdit
};

typedef NS_ENUM(NSUInteger, TutorialViewMode) {
    TutorialViewModeStartup = 0,
    TutorialViewModeSettings
};

typedef NS_ENUM(NSUInteger, ListNotificationType) {
    ListNotificationTypeInvite = 0,
    ListNotificationTypeUpdate,
    ListNotificationTypeCancel
};

typedef NS_ENUM(NSUInteger, ChatViewMode) {
    ChatModeGroup = 0,
    ChatModeSingle
};
#endif
