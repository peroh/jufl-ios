//
//  PrivateChatListCell.m
//  jufl
//
//  Created by Dhirendra Kumar on 1/25/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import "PrivateChatListCell.h"

@implementation PrivateChatListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setPrivateChatListCellData :(PrivateChatListModel *)chatList {
    self.unreadMegCountLbl.layer.cornerRadius = 12.5;
    self.unreadMegCountLbl.layer.borderWidth = 0.0;

    self.userImgView.layer.cornerRadius = 22.5;
    self.userImgView.clipsToBounds = YES;
        if([chatList.image hasSuffix:@"jpg"]){
            NSURL *urlImg = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",chatList.imagePath,chatList.image]];
            [self.userImgView sd_setImageWithURL:urlImg placeholderImage:imgSync completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!image) {
                    self.userImgView.image = [UIImage imageNamed:@"contactPlaceholder"];
                }
                self.userImgView.contentMode = UIViewContentModeScaleAspectFit;
    
            } animation:NaveenImageViewOptionsNone];
        }
     else {
    self.userImgView.image = [UIImage imageNamed:@"contactPlaceholder"];
    }
    self.userNameLbl.text = [NSString stringWithFormat:@"%@ %@",chatList.fisrtName,chatList.lastName];
    
    self.unreadMegCountLbl.text = [NSString stringWithFormat:@"%@",chatList.unreadMsgCount];
    if ([self.unreadMegCountLbl.text isEqualToString:@"0"]) {
        self.unreadMegCountLbl.hidden = YES;
    }
    else{
        self.unreadMegCountLbl.hidden=NO;
    }
    
}

@end
