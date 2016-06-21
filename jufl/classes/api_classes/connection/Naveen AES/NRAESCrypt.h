//
//  NRAESCrypt.h
//  AroundAbout
//
//  Created by Naveen Rana on 15/12/14.
//  Copyright (c) 2014 Naveen Rana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRAESCrypt : NSObject

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;
+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password;

@end
