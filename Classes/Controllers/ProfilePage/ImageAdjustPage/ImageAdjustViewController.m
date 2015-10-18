//
//  ImageAdjustViewController.m
//  MyScene
//
//  Created by Vikash on 04/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#define NavigationHeight 64
#define ButtonPadding 80

#import "ImageAdjustViewController.h"

@interface ImageAdjustViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retakeButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipViewTopSpace;

@end

@implementation ImageAdjustViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CGFloat diameter;
    if ([self isPortraitInterfaceOrientation]) {
        diameter = MIN(viewWidth, viewHeight) - kPortraitCircleMaskRectInnerEdgeInset * 2;
    } else {
        diameter = MIN(viewWidth, viewHeight) - kLandscapeCircleMaskRectInnerEdgeInset * 2;
    }
    
    diameter += 60;
    
    CGSize maskSize = CGSizeMake(diameter, diameter);
    
    _tipViewTopSpace.constant = maskSize.height+15;
    
    _retakeButtonWidth.constant = ([UIScreen mainScreen].bounds.size.width-ButtonPadding)/2;
    
    [self.view layoutIfNeeded];
}

@end
