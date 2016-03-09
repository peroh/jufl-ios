//
//  KeyboardListener.m
//  PairedUp
//
//  Created by IPNONE-12 on 13/03/13.
//  Copyright (c) 2013 Org. All rights reserved.
//

#import "KeyboardListener.h"
#define RETURN_SINGLETON(class) \
static id sharedInstance = nil; \
@synchronized(self) \
{ \
if (!sharedInstance) \
sharedInstance = [[class alloc] init]; \
} \
return sharedInstance


@interface KeyboardListener ()

//@property (nonatomic, readwrite) BOOL isKeyboardVisible;

- (void)willShow:(NSNotification *)notification;
- (void)didShow:(NSNotification *)notification;
- (void)willHide:(NSNotification *)notification;
- (void)didHide:(NSNotification *)notification;
- (CGSize)sizeFromDict:(NSNotification *)notification;
- (CGRect)rectFromDict:(NSNotification *)notification;
- (NSTimeInterval)durationFromDict:(NSNotification *)notification;
- (UIViewAnimationCurve)curveFromDict:(NSNotification *)notification;

@end


#pragma mark -


@implementation KeyboardListener


@synthesize delegate;
@synthesize isKeyboardVisible;


+ (KeyboardListener *)sharedInstance
{
	RETURN_SINGLETON (KeyboardListener);
}


- (id)init
{
	if (self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHide:) name:UIKeyboardWillHideNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHide:) name:UIKeyboardDidHideNotification object:nil];
	}
	
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	
	self.delegate = nil;
}


- (void)willShow:(NSNotification *)notification
{
	if (nil != self.delegate)
	{
		if ([self.delegate respondsToSelector:@selector(keyboardWillShowWithSize:duration:andCurve:)])
		{
			[self.delegate keyboardWillShowWithSize:[self rectFromDict:notification]
										   duration:[self durationFromDict:notification]
										   andCurve:[self curveFromDict:notification]];
		}
	}
}


- (void)didShow:(NSNotification *)notification
{
	self.isKeyboardVisible = YES;
	if (nil != self.delegate)
	{
		if ([self.delegate respondsToSelector:@selector(keyboardDidShowWithSize:duration:andCurve:)])
		{
			[self.delegate keyboardDidShowWithSize:[self rectFromDict:notification]
										  duration:[self durationFromDict:notification]
										  andCurve:[self curveFromDict:notification]];
		}
	}
}


- (void)willHide:(NSNotification *)notification
{
	if (nil != self.delegate)
	{
		if ([self.delegate respondsToSelector:@selector(keyboardWillHideWithSize:duration:andCurve:)])
		{
			[self.delegate keyboardWillHideWithSize:[self rectFromDict:notification]
										   duration:[self durationFromDict:notification]
										   andCurve:[self curveFromDict:notification]];
		}
	}
}


- (void)didHide:(NSNotification *)notification
{
	self.isKeyboardVisible = NO;
	if (nil != self.delegate)
	{
		if ([self.delegate respondsToSelector:@selector(keyboardDidHideWithSize:duration:andCurve:)])
		{
			[self.delegate keyboardDidHideWithSize:[self rectFromDict:notification]
										  duration:[self durationFromDict:notification]
										  andCurve:[self curveFromDict:notification]];
		}
	}
}


- (CGSize)sizeFromDict:(NSNotification *)notification
{
	return [self rectFromDict:notification].size;
}

- (CGRect)rectFromDict:(NSNotification *)notification
{
	return [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}


- (NSTimeInterval)durationFromDict:(NSNotification *)notification
{
	NSTimeInterval duration;
	[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
	return duration;
}


- (UIViewAnimationCurve)curveFromDict:(NSNotification *)notification
{
	UIViewAnimationCurve curve;
	[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
	return curve;
}


@end
