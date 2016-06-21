//
//  ChatTableViewCell.h
//  jufl
//
//  Created by Dhirendra Kumar on 1/20/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"
@interface ChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLbl;
@property (weak, nonatomic) IBOutlet UIButton *loadMsgButton;
- (void)setChatCellData:(ChatModel *)chatData;;
@end
