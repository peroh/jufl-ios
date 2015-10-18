//
//  Configuration.m
//  WorldFormula
//
//  Created by Naveen Rana on 10/07/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import "Configuration.h"
#import "AppDelegate.h"
#import "TSMessage.h"

@implementation Configuration

+ (NSString *)getBaseURL
{
    NSString *baseURL =nil;

#ifdef DEBUG
    
    // Something to log your sensitive data here
//    baseURL = @"http://52.64.118.150/jufl/public/api"; // DEV URL
#warning @"chnage url"
    baseURL = @"http://54.153.198.29/jufl/public/api"; // QA URL
   
    
#endif
#ifdef QARELEASE
    
    baseURL = @"http://54.153.198.29/jufl/public/api"; // QA URL
    
#endif
  
    
#ifdef RELEASE
    
   // baseURL = @"http://54.66.156.48/jufl/public/api"; // Production URL
    baseURL = @"https://admin.jufl.io/api"; // Production URL

    
#endif

    return baseURL;

}

+ (void)serverName
{
    
#ifdef DEBUG
    
    // Something to log your sensitive data here
    [TSMessage showNotificationInViewController:appDelegate.window.rootViewController title:@"Debug Server" subtitle:@"" type:TSMessageNotificationTypeWarning];
#endif
#ifdef QARELEASE
    [TSMessage showNotificationInViewController:appDelegate.window.rootViewController title:@"QA Server" subtitle:@"" type:TSMessageNotificationTypeWarning];
    
#endif
    
    
#ifdef RELEASE
    [TSMessage showNotificationInViewController:appDelegate.window.rootViewController title:@"Production" subtitle:@"" type:TSMessageNotificationTypeWarning];
    
#endif
    
    
}

+(NSString *)getMixpanelToken
{
    NSString *mixpanelToken =nil;
    
#ifdef DEBUG
    
    // Something to log your sensitive data here
    mixpanelToken = @"5789e78f9817806e83c0ac653ba2ab2a"; // DEV Token
    
#endif
#ifdef QARELEASE
    
    mixpanelToken = @"e16af8fd47779c6a2d4424045f802fa3"; // QA Token
    
#endif
#ifdef RELEASE
    
    mixpanelToken = @"0badc9e71839d489c935572d8ac7e832"; // Production Token
    //mixpanelToken = @"586a6e9cf588ae80ec24bda8f57cc765"; // Staging Token
    
#endif
    
    return mixpanelToken;
}

@end
