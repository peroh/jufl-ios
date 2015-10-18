//
//  Configuration.h
//  WorldFormula
//
//  Created by Naveen Rana on 10/07/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configuration : NSObject

+ (NSString *)getBaseURL;
+ (void)serverName;
+(NSString *)getMixpanelToken;
@end
