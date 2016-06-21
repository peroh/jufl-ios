//
//  NotificationTableViewCell.h
//  JUFL
//
//  Created by Ankur on 10/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *seeMoreButton;

- (void)setNotificationData:(NotificationModel *)notification;
@end
