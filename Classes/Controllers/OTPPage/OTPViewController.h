//
//  OTPViewController.h
//  JUFL
//
//  Created by Ankur Arya on 08/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTPViewController : UIViewController

- (instancetype)initWithVerificationCode:(NSString *)code userModel:(UserModel *)user;

@end
