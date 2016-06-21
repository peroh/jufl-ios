//
//  EventCreatedViewController.h
//  JUFL
//
//  Created by Ankur on 18/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCreatedViewController : UIViewController
- (instancetype)initWithEventModel:(EventModel *)event andFriends:(NSString *)totalFriends;
- (instancetype)initWithFriends:(NSString *)totalFriends;
@end
