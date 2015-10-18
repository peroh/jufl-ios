//
//  CurvedTop.h
//  Terms
//
//  Created by Sashi Bhushan on 30/04/15.
//  Copyright (c) 2015 Sashi Bhushan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurvedTop : UIView

@property (strong, nonatomic) IBInspectable UIColor *backColor;

- (void)toggleShow:(BOOL)open;
- (void)setBackColor:(UIColor *)backColor;
@end
