//
//  KeyboardListener.h
//  PairedUp
//
//  Created by IPNONE-12 on 13/03/13.
//  Copyright (c) 2013 Org. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyboardListenerDelegate;

@interface KeyboardListener : NSObject
{
	//id <KeyboardListenerDelegate> delegate;
	BOOL isKeyboardVisible;
}

@property (nonatomic, strong) id <KeyboardListenerDelegate> delegate;
@property (nonatomic, assign) BOOL isKeyboardVisible;

+ (KeyboardListener *)sharedInstance;
//+ (KeyboardListener *)listenerWithDelegate:(id <KeyboardListenerDelegate>)delegate_;

@end


#pragma mark -


@protocol KeyboardListenerDelegate <NSObject>

@optional

- (void)keyboardWillShowWithSize:(CGRect)rect duration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve;
- (void)keyboardDidShowWithSize:(CGRect)rect duration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve;
- (void)keyboardWillHideWithSize:(CGRect)rect duration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve;
- (void)keyboardDidHideWithSize:(CGRect)rect duration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve;


@end