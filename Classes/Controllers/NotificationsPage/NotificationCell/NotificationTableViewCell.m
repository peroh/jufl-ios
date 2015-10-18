//
//  NotificationTableViewCell.m
//  JUFL
//
//  Created by Ankur on 10/08/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotificationData:(NotificationModel *)notification {
    if (notification) {
        
        NSString *timeString = @"";
        if([notification.event.startTime isToday]) {
            timeString = [NSString stringWithFormat:@"today at %@",[notification.event.startTime stringWithFormat:@"hh:mm a"]];//[self getAttributedString: :event.location.name];
        }
        else if ([notification.event.startTime isTomorrow]) {
            timeString = [NSString stringWithFormat:@"tomorrow at %@",[notification.event.startTime stringWithFormat:@"hh:mm a"]];//[self getAttributedString: :event.location.name];
        }
        else {
            timeString = [NSString stringWithFormat:@"on %@",[notification.event.startTime string]];//[self getAttributedString: :event.location.name];
        }
        
        NSString *notificationTimeString = @"";
        if([notification.notificationTime isToday]) {
            notificationTimeString = [NSString stringWithFormat:@"today %@",[[notification.notificationTime stringWithFormat:@"hh:mm a"]localDateStringWithFormat:@"hh:mm a"]];//[self getAttributedString: :event.location.name];
        }
        else if ([notification.notificationTime isTomorrow]) {
            notificationTimeString = [NSString stringWithFormat:@"tomorrow %@",[[notification.notificationTime stringWithFormat:@"hh:mm a"]localDateStringWithFormat:@"hh:mm a"]];//[self getAttributedString: :event.location.name];
        }
        else {
            notificationTimeString = [[notification.notificationTime string] localDateStringWithFormat:@"hh:mm a dd/MM/yy"];//[self getAttributedString: :event.location.name];
        }
        
        self.userImageView.layer.cornerRadius = 22.5;
        self.userImageView.clipsToBounds = YES;
        if([notification.event.creator.image hasSuffix:@"jpg"]){
        [self.userImageView sd_setImageWithURL:[NSURL URLWithString:notification.event.creator.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                self.userImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
            }
            self.userImageView.contentMode = UIViewContentModeScaleAspectFit;
            
        } animation:NaveenImageViewOptionsNone];
        }
        else {
            self.userImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
        }
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",notification.event.creator.firstName,notification.event.creator.lastName];
        if (notification.notificationType == ListNotificationTypeInvite) {
            self.notificationMessageLabel.attributedText = [self getAttributedString:[NSString stringWithFormat:@"%@ %@.",[notification.messageString substringToIndex:notification.messageString.length],timeString] :notification.event.name];
        }
        else if (notification.notificationType == ListNotificationTypeCancel) {
            
            self.notificationMessageLabel.attributedText = [self getAttributedString:[NSString stringWithFormat:@"%@",notification.messageString] :notification.event.name];
        }
        else {
            self.notificationMessageLabel.attributedText = [self getAttributedString:[NSString stringWithFormat:@"%@.",notification.messageString] :notification.event.name];
        }
        
        self.notificationTimeLabel.text = notificationTimeString;
    }
}

-(NSMutableAttributedString *)getAttributedString:(NSString *)firstString :(NSString *)secondString {
    
    NSMutableAttributedString *showAttributedString = [[NSMutableAttributedString alloc]initWithString:firstString];
    
    NSRange range = [firstString rangeOfString:secondString];
    
    NSDictionary *secondAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(13.0),NSForegroundColorAttributeName: Rgb2UIColor(255, 68, 67)};
    
    NSDictionary *firstAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(13.0),NSForegroundColorAttributeName: Rgb2UIColor(109, 110, 113)};
    
    [showAttributedString addAttributes:firstAttributes range:NSMakeRange(0,showAttributedString.length)];
    [showAttributedString addAttributes:secondAttributes range:range];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:2];
    [paragrahStyle setAlignment:NSTextAlignmentLeft];
    [showAttributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [showAttributedString length])];
    
    return showAttributedString;
}


@end
