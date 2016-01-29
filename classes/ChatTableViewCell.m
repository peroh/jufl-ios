//
//  ChatTableViewCell.m
//  jufl
//
//  Created by Dhirendra Kumar on 1/20/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setChatCellData:(ChatModel *)chatData  {
   
    self.userImgView.layer.cornerRadius = 22.5;
    self.userImgView.clipsToBounds = YES;
    if([chatData.image hasSuffix:@"jpg"]){
        [self.userImgView sd_setImageWithURL:[NSURL URLWithString:chatData.image] placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                self.userImgView.image = [UIImage imageNamed:@"contactPlaceholder"];
            }
            self.userImgView.contentMode = UIViewContentModeScaleAspectFit;
            
        } animation:NaveenImageViewOptionsNone];
    }
    else {
        self.userImgView.image = [UIImage imageNamed:@"contactPlaceholder"];
    }
    
    self.userNameLbl.text = [NSString stringWithFormat:@"%@ %@",chatData.fisrtName,chatData.lastName];
    self.messageLbl.text = [NSString stringWithFormat:@"%@",chatData.message];
    
    self.dateTimeLbl.text = [NSString stringWithFormat:@"%@",[chatData.chatDateTime stringWithFormat:@"hh:mm a"]];

}
@end
