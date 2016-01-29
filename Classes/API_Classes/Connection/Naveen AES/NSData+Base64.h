//
//  NSData+Base64.m
//  NAVEEN RANA
//
//  Created by NAVEEN RANA

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (Base64Additions)

+ (NSData *)base64DataFromString:(NSString *)string;

@end