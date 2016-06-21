//
//  CurvedTop.m
//  Terms
//
//  Created by Sashi Bhushan on 30/04/15.
//  Copyright (c) 2015 Sashi Bhushan. All rights reserved.
//

#import "CurvedTop.h"

IB_DESIGNABLE
@implementation CurvedTop
{
    CAShapeLayer *layer;
    BOOL isOpen;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

-(void)layoutSubviews
{
    CGRect rect = self.bounds;
    self.backgroundColor = [UIColor clearColor];
    
    if(!layer)
        layer = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    if(isOpen)
    {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    else
    {
        [path moveToPoint:CGPointMake(0, 30)];
        [path addQuadCurveToPoint:CGPointMake(rect.size.width, 30) controlPoint:CGPointMake(rect.size.width/2, rect.origin.y-30)];
        [path addLineToPoint:CGPointMake(rect.size.width, rect.origin.y+rect.size.height)];
        [path addLineToPoint:CGPointMake(0, rect.origin.y+rect.size.height)];
        [path closePath];
    }
    
    
    layer.path = path.CGPath;
    if(_backColor)
        layer.fillColor = _backColor.CGColor;
    else
        layer.fillColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.85f].CGColor;
    
    [self.layer insertSublayer:layer atIndex:0];
}

-(void)toggleShow:(BOOL)open
{
    isOpen = open;
    [self layoutSubviews];
}

- (void)setBackColor:(UIColor *)backColor
{
    _backColor = backColor;
    [self layoutSubviews];
}


@end
