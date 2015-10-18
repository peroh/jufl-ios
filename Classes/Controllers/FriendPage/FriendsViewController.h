//
//  FriendsViewController.h
//  JUFL
//
//  Created by Ankur on 13/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewController : UIViewController

- (instancetype)initWithViewMode:(FriendViewMode)mode;
- (instancetype)initWithViewMode:(FriendViewMode)mode eventModel:(EventModel *)event;
- (instancetype)initWithViewMode:(FriendViewMode)mode eventModel:(EventModel *)event invitedUsers:(NSArray *)users;
- (void)checkContactPermission;

@end
