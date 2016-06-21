//
//  ProfileViewController.h
//  JUFL
//
//  Created by Ankur Arya on 09/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserModel;
@interface ProfileViewController : UIViewController

- (instancetype)initWithUser:(UserModel *)user;

@end
