//
//  InlineHeader.h
//  JUFL
//
//  Created by Ankur Arya on 08/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#ifndef JUFL_InlineHeader_h
#define JUFL_InlineHeader_h

inline static BOOL success(NSDictionary *response,NSError *error)
{
    if(!response)return NO;
    BOOL isSuccess =[[response objectForKey:kSuccess] boolValue];
    if(!isSuccess)
    {
        if(!error)
        {
            NSString *messageString;
            if ([[response objectForKey:kMessage] isEqualToString:@"Unauthorized."]) {
                messageString = @"This account is being used on other device.";
            }
            else {
                messageString = [response objectForKey:kMessage];
            }
            [Utils showOKAlertWithTitle:kTitle message:messageString];
            //[[Utils sharedInstance] showCustomOKAlertWithMessage:[response objectForKey:kMessage] completionHandler:nil];
            
        }
    }
    return isSuccess;
}


#endif
