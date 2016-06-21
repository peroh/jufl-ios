//
//  TouchView.m
//  ImageCropper
//
//  Created by Rakesh Lohan on 03/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        return self.receiver;
    }
    return nil;
}

@end
