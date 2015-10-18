//
//  CustomNavigationViewController.h
//  MyScene
//
//  Created by Naveen Rana on 30/03/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationViewController : UINavigationController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger viewTag;

@end
