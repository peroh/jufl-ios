//
//  ImageScrollView.h
//  ImageCropper
//
//  Created by Rakesh Lohan on 03/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView
@property (nonatomic, strong) UIImageView *zoomView;

- (void)displayImage:(UIImage *)image;

@end
