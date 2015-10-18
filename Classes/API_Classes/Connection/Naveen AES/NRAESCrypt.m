//
//  NRAESCrypt.m
//  AroundAbout
//
//  Created by Naveen Rana on 15/12/14.
//  Copyright (c) 2014 Naveen Rana. All rights reserved.
//

#import "NRAESCrypt.h"
#import "NSData+Base64.h"
#import "NSData+CommonCrypto.h"
#import "NSString+Base64.h"
@implementation NRAESCrypt

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password {
    NSData *encryptedData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
    return base64EncodedString;
}

+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password {
    NSData *encryptedData = [NSData base64DataFromString:base64EncodedString];
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}
@end
