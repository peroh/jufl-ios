//
//  PrivateChatListCell.h
//  jufl
//
//  Created by Dhirendra Kumar on 1/25/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateChatListModel.h"

@interface PrivateChatListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *unreadMegCountLbl;
- (void)setPrivateChatListCellData :(PrivateChatListModel *)chatList;
@end
