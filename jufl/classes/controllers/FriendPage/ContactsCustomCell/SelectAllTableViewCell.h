//
//  SelectAllTableViewCell.h
//  JUFL
//
//  Created by Ankur on 18/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAllTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;

@end
