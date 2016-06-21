//
//  FeedTableViewCell.m
//  JUFL
//
//  Created by Ankur on 21/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "FeedTableViewCell.h"

@implementation FeedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setCellData :(EventModel *)event {
    self.currentEvent = event;
    
    self.eventNameLabel.text = event.name;
    
    if([event.startTime isToday]) {
        self.eventDetailLabel.attributedText = [self getAttributedString:[NSString stringWithFormat:@"today %@",[event.startTime stringWithFormat:@"hh:mm a"]] :event.location.name];
    }
    else if ([event.startTime isTomorrow]) {
        self.eventDetailLabel.attributedText = [self getAttributedString:[NSString stringWithFormat:@"tomorrow %@",[event.startTime stringWithFormat:@"hh:mm a"]] :event.location.name];
    }
    else {
        self.eventDetailLabel.attributedText = [self getAttributedString:[event.startTime string] :event.location.name];
    }
    self.userImageView.layer.cornerRadius = 22.5;
    self.userImageView.clipsToBounds = YES;
    if([event.creator.image hasSuffix:@"jpg"]){
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:event.creator.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            self.userImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
        }
        self.userImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    } animation:NaveenImageViewOptionsNone];
    }
    else {
        self.userImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
    }
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",event.creator.firstName, event.creator.lastName];
    self.mineLabel.hidden = YES;
    NSNumber *currentId = numberValue([UserDefaluts objectForKey:kCurrentUserID]);
    if ([event.creator.userId isEqualToNumber:currentId]) {
        self.mineLabel.hidden = NO;
    }
    
    double distance = [[Location sharedInstance]getDistanceBetweenTwoCordinates:[kCurrentLatitude doubleValue] longitude1:[kCurrentLongitude doubleValue] latitude2:event.location.coordinate.latitude longitude2:event.location.coordinate.longitude]/1000; //distance in km
    self.distanceInKM = [NSString stringWithFormat:@"%.2f km",distance];
    self.distanceInMiles = [NSString stringWithFormat:@"%.2f mile",distance/1.61];
    self.locationLabel.text =[NSString stringWithFormat:@"%.2f km",distance];
    self.goingLabel.text = [NSString stringWithFormat:@"%@ going",event.goingCount];
    if (!event.isDeleted) {
    if ([event.startTime isEarlierThanDate:[NSDate date]]) {
        if ([event.endTime isLaterThanDate:[NSDate date]]) {
            self.eventTimeLabel.text = @"Now";
            self.eventTimeLabel.font = FONT_ProximaNova_Bold_WITH_SIZE(13.0);
        }
        else {
            self.eventTimeLabel.text = [NSDate stringForDisplayFromDate:event.startTime];
            self.eventTimeLabel.font = FONT_ProximaNova_Light_WITH_SIZE(13.0);
        }
    }
    else {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"in %@",[NSDate stringForDisplayToDate:event.startTime]];
        self.eventTimeLabel.font = FONT_ProximaNova_Light_WITH_SIZE(13.0);
    }
    }
    else {
        self.eventTimeLabel.text = @"Cancelled";
        self.eventTimeLabel.font = FONT_ProximaNova_Bold_WITH_SIZE(13.0);
    }
    
}

-(NSMutableAttributedString *)getAttributedString:(NSString *)firstString :(NSString *)secondString {
    
    NSMutableAttributedString *showAttributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",firstString, secondString]];
    
    NSDictionary *secondAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Semibold_WITH_SIZE(13.0),NSForegroundColorAttributeName: Rgb2UIColor(109, 110, 113)};
    
    NSDictionary *firstAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(13.0),NSForegroundColorAttributeName: Rgb2UIColor(109, 110, 113)};
    
    [showAttributedString addAttributes:firstAttributes range:NSMakeRange(0,showAttributedString.length)];
    [showAttributedString addAttributes:secondAttributes range:NSMakeRange(0, firstString.length)];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:4];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    [showAttributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [showAttributedString length])];
    
    return showAttributedString;
}

- (void)setCountdownTime :(EventModel *)event {
    if (!event.isDeleted) {
        if ([event.startTime isEarlierThanDate:[NSDate date]]) {
            if ([event.endTime isLaterThanDate:[NSDate date]]) {
                self.eventTimeLabel.text = @"Now";
            }
            else {
                self.eventTimeLabel.text = [NSDate stringForDisplayFromDate:event.startTime];
            }
        }
        else {
            self.eventTimeLabel.text = [NSString stringWithFormat:@"in %@",[NSDate stringForDisplayToDate:event.startTime]];
            
        }
    }
    else {
        self.eventTimeLabel.text = @"Cancelled";
    }
}

- (void)setEventTime :(EventModel *)event {
    if([event.startTime isToday]) {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"Today %@",[event.startTime stringWithFormat:@"hh:mm a"]];
    }
    else if ([event.startTime isTomorrow]) {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"Tomorrow %@",[event.startTime stringWithFormat:@"hh:mm a"]];
    }
    else {
        self.eventTimeLabel.text = [event.startTime string];
    }
}
- (IBAction)locationClicked:(id)sender {
    self.locationButton.selected = !self.locationButton.selected;
    if (self.locationButton.selected) {
        self.locationLabel.text = self.distanceInMiles;
    }
    else {
        self.locationLabel.text = self.distanceInKM;
    }
}
- (IBAction)timeClicked:(id)sender {
    self.timeButton.selected = !self.timeButton.selected;
    if (self.timeButton.selected) {
        [self setEventTime:self.currentEvent];
    }
    else {
        [self setCountdownTime:self.currentEvent];
    }
}

@end
