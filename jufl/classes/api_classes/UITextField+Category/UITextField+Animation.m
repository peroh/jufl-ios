//
//  UITextField+Animation.m
//  TwistLite
//
//  Created by CultureSphere on 10/12/13.
//  Copyright (c) 2013 CultureSphere. All rights reserved.
//

#import "UITextField+Animation.h"
#define KEYBOARD_ANIMATION_DURATION 0.2
#define MINIMUM_SCROLL_FRACTION 0.2
#define MAXIMUM_SCROLL_FRACTION 0.8
#define PORTRAIT_KEYBOARD_HEIGHT 216

CGFloat animatedDistance;

@implementation UITextField (Animation)

-(void)keyboardOpenIn:(UIView *)vw
{
    /*  For Textfield not hide in Keybord   */
    
    CGRect textVWRect = [vw convertRect:self.bounds fromView:self];
	CGRect viewRect = [vw convertRect:vw.bounds fromView:vw];
	CGFloat midline = textVWRect.origin.y + 0.1 * textVWRect.size.height;
	CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
	CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
	CGFloat heightFraction = numerator / denominator;
	if (heightFraction < 0.0){
		heightFraction = 0.0;
	}else if (heightFraction > 1.0){
		heightFraction = 1.0;
	}
	animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    CGRect viewFrame = vw.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [vw setFrame:viewFrame];
    [UIView commitAnimations];
}
-(void)keyboardCloseIn:(UIView *)vw
{
    CGRect viewFrame = vw.frame;
	viewFrame.origin.y += animatedDistance;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[vw setFrame:viewFrame];
	[UIView commitAnimations];
}
@end
