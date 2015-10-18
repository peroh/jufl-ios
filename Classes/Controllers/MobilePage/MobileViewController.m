//
//  MobileViewController.m
//  JUFL
//
//  Created by Ankur Arya on 08/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import "MobileViewController.h"
#import "CountryPicker.h"
#import "OTPViewController.h"
#import "Mixpanel.h"
#import "IQKeyboardManager.h"
#import "TermsViewController.h"

#define kPhoneNumberLength 14
@interface MobileViewController ()<UITextFieldDelegate, CountryPickerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (strong, nonatomic) CountryPicker *countryPicker;
@property (strong, nonatomic) NSDictionary *codeDict;
@property (weak, nonatomic) IBOutlet UIButton *verificationButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UILabel *tncLabel;

@end

@implementation MobileViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self initializeView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [self.mobileTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    RESIGN_KEYBOARD;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My functions

- (void)initializeView {
    
    self.codeDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DailingCodes" ofType:@"plist"]];
    
    self.countryPicker = [[CountryPicker alloc] init];
    [self.countryPicker setSelectedLocale:[NSLocale currentLocale] animated:NO];
    self.countryCodeTextField.text = [NSString stringWithFormat:@"+%@",self.codeDict[self.countryPicker.selectedCountryCode]];
    self.countryPicker.delegate = self;
    
    [self.countryCodeTextField setInputView:self.countryPicker];
    
    //    [self.countryCodeTextField paddingTextField:self.countryCodeTextField :10];
    [self.mobileTextField paddingTextField:self.mobileTextField :10];
    self.countryCodeTextField.layer.borderWidth = 1.5;
    self.mobileTextField.layer.borderWidth = 1.5;
    self.countryCodeTextField.layer.borderColor = Rgb2UIColor(170, 170, 170).CGColor;
    self.mobileTextField.layer.borderColor = Rgb2UIColor(170, 170, 170).CGColor;
    NSString *verifyString = @"By verifying you agree to our\n";
    NSString *tncString = @"Terms & Conditions";
    NSMutableAttributedString *tncAttributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",verifyString,tncString]];
    
    NSDictionary *verifyAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(15.0),NSForegroundColorAttributeName: Rgb2UIColor(65, 64, 66)};
    
    NSDictionary *tncAttributes =  @{NSFontAttributeName:FONT_ProximaNova_Light_WITH_SIZE(15.0),NSForegroundColorAttributeName: Rgb2UIColor(33, 205, 182)};
    
    [tncAttributedString addAttributes:verifyAttributes range:NSMakeRange(0,verifyString.length)];
    [tncAttributedString addAttributes:tncAttributes range:NSMakeRange(verifyString.length, tncString.length)];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:4];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    [tncAttributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [tncAttributedString length])];
    
    self.tncLabel.attributedText = tncAttributedString;
    self.termsButton.hidden = YES;
    self.tncLabel.hidden = YES;
    [self.mobileTextField becomeFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.termsButton.hidden = NO;
        self.tncLabel.hidden = NO;

    });
    
}

- (void)verifyMobileNumber {
    [UserModel verifyMobileNumber:self.mobileTextField.text withCountryCode:self.countryCodeTextField.text completion:^(BOOL success, UserModel *currentUser, NSString *otp, NSError *error) {
        if (success) {
            
            NSString *phoneNumber=[NSString stringWithFormat:@"%@%@",self.countryCodeTextField.text,self.mobileTextField.text];
            [[Mixpanel sharedInstance] track:@"UsersCount" properties:@{@"Phone number" : phoneNumber}];
            
//            [[Mixpanel sharedInstance] track:@"Users" properties:@{@"Country Code" : self.countryCodeTextField.text,@"Phone number" : self.mobileTextField.text}];
//
//            #warning Remove alert;
//            [[Utils sharedInstance]openAlertViewWithTitle:kTitle message:otp buttons:@[@"Ok"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
//                
//            }];
            [self goToVerificationPage:otp user:currentUser];
        }
        else {
            
        }
        
    }];
}

- (void)goToVerificationPage: (NSString *)otp user:(UserModel *)loggedInUser{
    OTPViewController *otpViewController = [[OTPViewController alloc]initWithVerificationCode:otp userModel:loggedInUser];
    [self.navigationController pushViewController:otpViewController animated:YES];
    
}
#pragma mark - IBActions
- (IBAction)verificationClicked:(id)sender {
    if ([NRValidation isValidPhoneNumber:self.mobileTextField.text]) {
        RESIGN_KEYBOARD
        [self verifyMobileNumber];
        //        [self goToVerificationPage];
    }
    else {
        [TSMessage showNotificationInViewController:self title:@"Invalid mobile number" subtitle:@"Please enter correct mobile number." type:TSMessageNotificationTypeMessage];
    }
}

- (IBAction)termsClicked:(id)sender {
    TermsViewController *termsViewController = [[TermsViewController alloc]initWithNibName:NSStringFromClass([TermsViewController class]) bundle:nil];
    [self presentViewController:termsViewController animated:YES completion:nil];
}

#pragma mark - Delegates
#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length == 0 && [string isEqualToString:@"0"]) {
        return NO;
    }
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength > 7) {
        self.verificationButton.backgroundColor = Rgb2UIColor(33, 205, 182);
        self.verificationButton.enabled = YES;
    }
    else {//Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
        self.verificationButton.backgroundColor = Rgb2UIColorWithAlpha(97, 97, 97, 0.4);
        self.verificationButton.enabled = NO;
        
    }
    return newLength <= kPhoneNumberLength;
}

#pragma mark - Country Delegate
- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    self.countryCodeTextField.text = [NSString stringWithFormat:@"+%@",self.codeDict[code]];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    RESIGN_KEYBOARD
//}
// block Menucontroller
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    return [super canPerformAction:action withSender:sender];
}
@end
