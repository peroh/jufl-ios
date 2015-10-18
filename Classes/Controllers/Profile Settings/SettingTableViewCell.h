//
//  SettingTableViewCell.h
//  JUFL
//
//  Created by Rakesh Lohan on 29/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *indexLabel;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;

@end
