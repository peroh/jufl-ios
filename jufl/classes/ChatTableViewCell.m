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
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setChatCellData:(ChatModel *)chatData  {
   
    self.userImgView.layer.cornerRadius = 22.5;
    self.userImgView.clipsToBounds = YES;
    //DLog(@"grrrrrr imag-- %@ First name----- %@ Last name-----%@ maessage---- %@",chatData.image,chatData.fisrtName,chatData.lastName,chatData.message);
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
    
    /********************Decode Data********************/
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:chatData.message options:0];
    
    
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    DLog(@"Decoded: %@", base64Decoded);
    self.messageLbl.text = [NSString stringWithFormat:@"%@",base64Decoded];
    /********************Decode Data********************/
    
    if([chatData.chatDateTime isYesterday]) {
        self.dateTimeLbl.text = @"Yesterday";
        //[NSString stringWithFormat:@"Today %@",[chatData.chatDateTime stringWithFormat:@"hh:mm a"]];
    }
    else if ([chatData.chatDateTime isToday]) {
        self.dateTimeLbl.text = [NSString stringWithFormat:@"%@",[chatData.chatDateTime stringWithFormat:@"hh:mm a"]];
        //[NSString stringWithFormat:@"Tomorrow %@",[chatData.chatDateTime stringWithFormat:@"hh:mm a"]];
    }
    else {
        self.dateTimeLbl.text = [chatData.chatDateTime string];
    }
    //self.dateTimeLbl.text = [NSString stringWithFormat:@"%@",[chatData.chatDateTime stringWithFormat:@"hh:mm a"]];

}

@end
