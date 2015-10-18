//
//  NRValidation.h
//  MyScene
//
//  Created by Naveen Rana on 02/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRValidation : NSObject

+(BOOL)isAlphanumericReferralCode:(NSString *)string;
+(BOOL)isValidString:(NSString *)string; // Check the string is empty or not
+ (BOOL)validateEmailTextField:(UITextField *)emailTextField;  //check for valid email and shake the textfield if its not valid
+ (BOOL)isValidEmailAddress:(NSString *)email;// check for valid email address
+ (BOOL)validatePasswordTextField:(UITextField *)textField;  //check for valid password textfield if its not valid and show corresponding alert message
+ (BOOL)validatePasswordAndConfirmPasswordTextField:(UITextField *)textField confirmPAsswordTextField:(UITextField *)confirmPasswordtextField;  //check if password and confirm password are equal
+ (BOOL)isValidPhoneNumber:(NSString *)phone; // check if given phone number is valid or not
+ (BOOL)isValidObject:(id)object; // check if it not nil or null
+ (NSString *)getValidDeviceToken:(NSData *)deviceToken; //Get valid device push notification

+ (NSString *)getValidString:(NSString *)string; //Get valid String


//Check for devices
+ (BOOL)isiPhone4;
+ (BOOL)isiPhone5;
+ (BOOL)isiPhone6;
+ (BOOL)isiPhone6Plus;

#define kEmailBlankMessage @"Please enter email"
#define kEmailIncorrectMessage @"Please enter valid email"


@end
