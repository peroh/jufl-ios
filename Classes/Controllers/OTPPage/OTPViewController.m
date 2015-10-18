//
//  OTPViewController.m
//  JUFL
//
//  Created by Ankur Arya on 08/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "OTPViewController.h"
#import "ProfileViewController.h"
#import "AFViewShaker.h"
#import "Mixpanel.h"

#define kOTPLength 4

@interface OTPViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (nonatomic, strong) NSString *verificationCode;
@property (nonatomic, strong) UserModel *loggedInUser;
@property (weak, nonatomic) IBOutlet UITextField *otpTextField;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@end

@implementation OTPViewController

#pragma mark - View life cycle

- (instancetype)initWithVerificationCode:(NSString *)code userModel:(UserModel *)user{
    
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.verificationCode = code;
        self.loggedInUser = user;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My functions

- (void)initializeView {
    
    [self.otpTextField paddingTextField:self.otpTextField :15];
    self.otpTextField.layer.borderWidth = 1.5;
    self.otpTextField.layer.borderWidth = 1.5;
    self.otpTextField.layer.borderColor = Rgb2UIColor(170, 170, 170).CGColor;
    [self.otpTextField becomeFirstResponder];
}

- (void)goToProfile {
    [Utils createBackGroundQueue:^{
        [self fetchContacts];
    }];
    ProfileViewController *profileViewController = [[ProfileViewController alloc]initWithUser:self.loggedInUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)fetchContacts {
    [[Contacts sharedInstance]fetchContactsFromAddressBookWithHandler:^(BOOL success, NSArray *appUser, NSArray *nonAppUser, NSError *error) {
        [Utils stopActivityIndicatorInView];
    }];
}
#pragma mark - IBActions

- (IBAction)confirmAction:(id)sender {
    [UserDefaluts setObject:[NSDate date] forKey:kLoginTime];
    if ([self.otpTextField.text isEqualToString:self.verificationCode]) {
        [CoreDataHandler saveUserDataWithModel:self.loggedInUser];
        
         [self goToProfile];
    }
    else {
        [AFViewShaker shakeViews:@[self.otpTextField]];
        self.otpTextField.text = @"";
        self.confirmButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
        self.confirmButton.enabled = NO;
        [TSMessage showNotificationInViewController:self title:@"Please enter correct OTP" subtitle:@"Click resend if you didn't receive OTP" type:TSMessageNotificationTypeMessage];
    }
   
}

- (IBAction)resendAction:(id)sender {
    [UserModel verifyMobileNumber:self.loggedInUser.mobileNo withCountryCode:self.loggedInUser.countryCode completion:^(BOOL success, UserModel *currentUser, NSString *otp, NSError *error) {
        if (success) {
            self.verificationCode = otp;
//#warning Remove alert;
//        [[Utils sharedInstance]openAlertViewWithTitle:kTitle message:otp buttons:@[@"Ok"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
//            
//        }];
        }
        
    }];
}

- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Delegates
#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength > 3) {
        self.confirmButton.backgroundColor = Rgb2UIColor(33, 205, 182);
        self.confirmButton.enabled = YES;
    }
    else {
        self.confirmButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
        self.confirmButton.enabled = NO;
        
    }
    return newLength <= kOTPLength;
}

@end
