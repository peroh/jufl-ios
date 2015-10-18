//
//  RoundImageView.m
//  MiVista
//
//  Created by Rohit Sharma on 15/05/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import "RoundImageView.h"

@implementation RoundImageView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.layer.cornerRadius = rect.size.width/2;
    self.clipsToBounds = YES;
    [self layoutIfNeeded];
}


@end
