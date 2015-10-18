//
//  TutorialCollectionViewCell.h
//  MiVista
//
//  Created by Ankur Arya on 30/06/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *tutImageView;
@property (weak, nonatomic) IBOutlet UILabel *tutTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tutDetailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

@end
