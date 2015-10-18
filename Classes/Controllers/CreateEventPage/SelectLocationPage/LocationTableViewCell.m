//
//  LocationTableViewCell.m
//  JUFL
//
//  Created by Ankur on 14/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "LocationTableViewCell.h"
#import "LocationModel.h"

@implementation LocationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLocationData:(LocationModel *)location {
    if (location) {
        self.locationAddress.text = location.address;
        self.locationName.text = location.name;
        if (location.imageString) {
            [self.locationImageView sd_setImageWithURL:[NSURL URLWithString:location.imageString] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                self.locationImageView.contentMode = UIViewContentModeScaleAspectFit;
            } animation:NaveenImageViewOptionsNone];
        }
        else {
            self.locationImageView.image = [UIImage imageNamed:@"locationPlaceholder"];
        }
        self.selectButton.selected = location.isLocationSelected;
    }
}

@end
