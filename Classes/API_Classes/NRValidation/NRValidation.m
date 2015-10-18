//
//  NRValidation.m
//  MyScene
//
//  Created by Naveen Rana on 02/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import "NRValidation.h"
#import "AFViewShaker.h"

//.........................................validation messages/..................................
#define kUserNameBlankMessage @"Please enter UserName"
#define kUserNameLengthMessage @"UserName must be at least 4 characters long"
#define kEmailBlankMessage @"Please enter email"
#define kEmailIncorrectMessage @"Please enter valid email"
#define kPAsswordBlankMessage @"Please enter your password"
#define kPAsswordLengthMessage @"Password must be at least 6 characters long"
#define kPAsswordConfirmPasswordnotMatchkMessage @"Password and Confirm Password not match"
#define kPasswordIncorrectMessage @"Password is incorrect,Please enter correct password"
#define kAcceptTermsnconditionMessage @"Please accept terms and conditions"

#define kInternalError                  @"Please try again"
#define kInternetConectionError         @"Please check your internet connection & try again"

//Forgot Password Screen
#define kForgotEmailBlankMessage @"Please enter registered email id"
#define kForgotMailSentMes sage @"Your Password is successfully sent to your email address"
#define kForgotEmailIncorrectMessage @"Entered email id doesn't exist"

#define kAlreadyLikeMessage    @"You already have liked it!"
#define kNoRecordMessage    @"No records found!"
#define kLanguageNotFoundMessage    @"No more languages avialable for this Gag!"
#define kCommentsNotAvaiiableMessage    @"Comments not available!"

@implementation NRValidation

+(BOOL)isValidString:(NSString *)string {  // Check the string is empty or not
    if(!string)
        return NO;
    BOOL isValid = NO;
    if([string respondsToSelector:@selector(length)]){
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        (string.length>0)?(isValid = YES):(isValid=NO);
    }
    return isValid;
}

+ (BOOL)validateEmailTextField:(UITextField *)emailTextField  //check for valid email and shake the textfield if its not valid and show corresponding alert message
{
    if(emailTextField.text.length==0)
    {
        [AFViewShaker shakeViews:@[emailTextField]];
        [Utils showToastWithMessage:kEmailBlankMessage];
        [emailTextField becomeFirstResponder];
        
        return NO;
    }
    
   else if(![NRValidation isValidEmailAddress:emailTextField.text] )
    {
        [AFViewShaker shakeViews:@[emailTextField]];
        [Utils showToastWithMessage:kEmailIncorrectMessage];
        return NO;
    }
    return YES;
}

+ (BOOL)isValidEmailAddress:(NSString *)email{ // check for valid email address
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
    
}

+ (BOOL)validatePasswordTextField:(UITextField *)textField  //check for valid password textfield if its not valid and show corresponding alert message
{
    if(textField.text.length==0)
    {
        [AFViewShaker shakeViews:@[textField]];
        [Utils showToastWithMessage:kPAsswordBlankMessage];
        [textField becomeFirstResponder];
        return NO;
    }
    else if(textField.text.length<6) // min 6 characters
    {
        [AFViewShaker shakeViews:@[textField]];
        [Utils showToastWithMessage:kPAsswordLengthMessage];
        [textField becomeFirstResponder];
        return NO;
    }
    return YES;
}

+ (BOOL)validatePasswordAndConfirmPasswordTextField:(UITextField *)textField confirmPAsswordTextField:(UITextField *)confirmPasswordtextField  //check if password and confirm password are equal
{
    if([NRValidation validatePasswordTextField:textField]&&[NRValidation validatePasswordTextField:confirmPasswordtextField])
    {
        if (![textField.text isEqualToString:confirmPasswordtextField.text])
        {
            [AFViewShaker shakeViews:@[textField,confirmPasswordtextField]];
            [Utils showToastWithMessage:kPAsswordConfirmPasswordnotMatchkMessage ];
            return NO;
            
        }

    }
    else if(textField.text.length<6)
    {
        [AFViewShaker shakeViews:@[textField]];
        [Utils showToastWithMessage:kPAsswordLengthMessage];
        [textField becomeFirstResponder];
        return NO;
    }
    return YES;
}

+ (BOOL)isValidPhoneNumber:(NSString *)phone // check if given phone number is valid or not
{
    if((phone.length < 7) || (phone.length>14))
        return NO;
    NSString *phoneRegex = @"^+(?:[0-9] ?){6,14}[0-9]$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}



+(BOOL)isAlphanumericReferralCode:(NSString *)string
{
    if((string.length < 6) || (string.length>6))
        return NO;
    NSString *filter = @"[a-z0-9]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filter];
    return [predicate evaluateWithObject:string];
}

+ (BOOL)isValidObject:(id)object // check if it not nil or null
{
    if (([object isKindOfClass:[NSNull class]])||object==nil) {
        return NO;
    }
    return YES;
}

+ (NSString *)getValidDeviceToken:(NSData *)deviceToken //Get valid device push notification
{
    NSString *validToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&lt;&gt;"]];
    validToken = [validToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    validToken = [validToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    validToken = [validToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    DLog(@"Device Token===%@",validToken);
    return validToken;
}

+ (NSString *)getValidString:(NSString *)string
{
    if([NRValidation isValidString:string])
        return string;
    return @"";
}

#pragma mark Check for devices
+ (BOOL)isiPhone4{
    if([[UIScreen mainScreen] bounds].size.height==480)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isiPhone5{
    if([[UIScreen mainScreen] bounds].size.height==568)
    {
        return YES;
    }
    return NO;
}
+ (BOOL)isiPhone6{
    if([[UIScreen mainScreen] bounds].size.height==667)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isiPhone6Plus{
    if([[UIScreen mainScreen] bounds].size.height==736)
    {
        return YES;
    }
    return NO;
}



@end
