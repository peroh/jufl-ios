//
//  ProfileImageViewController.h
//  JUFL
//
//  Created by Ankur on 24/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileImageViewController : UIViewController <UIAlertViewDelegate>

- (instancetype)initWithUser:(UserModel *)user;

@end
