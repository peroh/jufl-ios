//
//  CSAlertView.m
//  CultureSphere
//
//  Created by CultureSphere on 18/12/13.
//  Copyright (c) 2013 CultureSphere. All rights reserved.
//

#import "CSAlertView.h"
#import "UITextField+Animation.h"




const static CGFloat kCustomIOS7MotionEffectExtent = 10.0;

@interface CSAlertView ()

@end

@implementation CSAlertView
@synthesize useMotionEffects;

- (id)initWithTitle:(NSString *)title Body:(NSString *)body WithYesNO:(BOOL)isYesNO
{
    self = [super init];
    if (self) {
        
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:3.0];
        [self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        UIButton *btnBack = [[UIButton alloc] initWithFrame:self.frame];
        [btnBack addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnBack];
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"CSAlertView" owner:self options:nil];
        CSAlertView *vw;
        if (isYesNO) {
            vw = [arr objectAtIndex:1];
           // [vw.lblTitle1 TitlewithCustomFontLiteSemibold:20];
            //[vw.lblBody1 TitlewithCustomFontRegular:17];
            //vw.txt.font = [UIFont fontWithName:FONT_LIGHT size:17.0];
            
            [vw.lblTitle setText:title];
            [vw.lblBody setText:body];
           // [vw.btnOk TitlewithCustomFontRegular:17];
            //[vw.btnCancel TitlewithCustomFontRegular:17];
        }else{
            vw = [arr objectAtIndex:0];
           // [vw.lblTitle TitlewithCustomFontLiteSemibold:20];
           // [vw.lblBody TitlewithCustomFontRegular:17];
            
           // CGSize size = [body sizeWithFont:[vw.lblBody font] constrainedToSize:CGSizeMake(248, 500) lineBreakMode:NSLineBreakByWordWrapping];
            CGRect tempRect=[body boundingRectWithSize:CGSizeMake(248, 500) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [vw.lblBody font]} context:nil];
            CGSize size=tempRect.size;
            CGRect rect = vw.lblBody.frame;
            rect.size.height = size.height + 1;
            [vw.lblBody setFrame:rect];
            
            if ([title length] == 0 || !title) {
                [vw.lblTitle setHidden:YES];
                CGRect rect = vw.lblBody.frame;
                rect.origin.y = vw.lblTitle.frame.origin.y;
                [vw.lblBody setFrame:rect];
                [vw setFrame:CGRectMake(0, 0, vw.frame.size.width, 160+size.height)];
            }else{
                [vw.lblTitle setText:title];
                [vw setFrame:CGRectMake(0, 0, vw.frame.size.width, 184+size.height)];
            }
            [vw.lblBody setText:body];
        }
        UIButton *btn = (UIButton *)[vw viewWithTag:55];
        [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];

        UIButton *btn2 = (UIButton *)[vw viewWithTag:66];
        [btn2 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:vw];
        
        
        [vw setCenter:self.center];
        useMotionEffects = false;
    }
    return self;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField keyboardOpenIn:self.superview];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField keyboardCloseIn:self.superview];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)btnPressed:(id)sender
{
    [self.txt resignFirstResponder];
    //CSAlertView *alert = (CSAlertView *)[self.subviews objectAtIndex:1];
    [self setTag:[sender tag]];
    if ([sender tag] == 55) {
        self.onButtonTouchUpInside(self, buttonOK);
    }else{
        self.onButtonTouchUpInside(self, buttonCancel);
    }
}
- (void)show
{
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
#if (defined(__IPHONE_7_0))
    if (useMotionEffects) {
        [self applyMotionEffects];
    }
#endif
    
    self.layer.opacity = 0.5f;
    self.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         self.layer.opacity = 1.0f;
                         self.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];
}
- (void)applyMotionEffects {
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }
    
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);
    
    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);
    
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
    
    [self addMotionEffect:motionEffectGroup];
}
- (void)close
{
    CATransform3D currentTransform = self.layer.transform;
    
    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
    
    self.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    self.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}
@end
