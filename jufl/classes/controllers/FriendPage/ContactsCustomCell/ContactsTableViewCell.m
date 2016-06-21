//
//  ContactsTableViewCell.m
//  JUFL
//
//  Created by Ankur on 16/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "ContactsTableViewCell.h"

@implementation ContactsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.contactImageView.layer.cornerRadius = 55/2;
    self.contactImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAppUserData:(UserModel *)user {
    
    if([user.image hasSuffix:@"jpg"]){
        [self.contactImageView sd_setImageWithURL:[NSURL URLWithString:user.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                self.contactImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
            }
            self.contactImageView.contentMode = UIViewContentModeScaleAspectFit;
        } animation:NaveenImageViewOptionsNone];
    }
    else {
         self.contactImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
    }
    if (user.isBlocked) {
        self.contactNameLabel.textColor = [UIColor redColor];
        self.contactImageView.alpha = 0.5;
    }
    else {
        self.contactNameLabel.textColor = Rgb2UIColor(97, 97, 97);
        self.contactImageView.alpha = 1;
    }
    if ([user.userId isEqualToNumber:numberValue([UserDefaluts objectForKey:kCurrentUserID])]) {
        self.contactNameLabel.text = @"You";
    }
    else {
    self.contactNameLabel.text = [NSString stringWithFormat:@"%@ %@",user.firstName, user.lastName];
    }
}
- (void)setNonAppUserData:(Contacts *)user {
    if (user.image) {
        self.contactImageView.image = user.image;
    }
    else {
        self.contactImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
    }
    self.contactNameLabel.text = [NSString stringWithFormat:@"%@ %@",user.firstName, user.lastName];
    self.contactNameLabel.textColor = Rgb2UIColor(97, 97, 97);
    self.contactImageView.alpha = 1;
}
@end
