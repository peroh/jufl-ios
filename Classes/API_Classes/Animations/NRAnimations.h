//
//  NRAnimations.h
//  AroundAbout
//
//  Created by Naveen Rana on 23/12/14.
//  Copyright (c) 2014 Naveen Rana. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, NaveenImageViewOptions) {
    NaveenImageViewOptionsNone=-1,
    NaveenImageViewOptionDontUseDiskCache            = 1 << 0,  // dont use disk cache
    NaveenImageViewOptionDontUseConnectionCache      = 1 << 1,  // dont use system wide cache
    NaveenImageViewOptionDontUseCache                = (NaveenImageViewOptionDontUseDiskCache | NaveenImageViewOptionDontUseConnectionCache),
    NaveenImageViewOptionDontSaveDiskCache           = 1 << 2, // dont save to disk cache
    NaveenImageViewOptionShowActivityIndicator       = 1 << 3, // show activity indicator when loading
    NaveenImageViewOptionAnimateEvenCache            = 1 << 4, // by default no animation for cache image, force if set this
    NaveenImageViewOptionDontClearImageBeforeLoading = 1 << 5, // will not clear old image when loading
    // load disk image in background, sometimes when you load image in table view cell, loading image
    // in foreground will also make the scrolling not smooth, set this to load disk cache in background
    NaveenImageViewOptionsLoadDiskCacheInBackground  = 1 << 6,
    
    // transition effects
    NaveenImageViewOptionTransitionNone              = 0 << 20, // default
    NaveenImageViewOptionTransitionCrossDissolve     = 1 << 20,
    
    NaveenImageViewOptionTransitionScaleDissolve     = 2 << 20,
    NaveenImageViewOptionTransitionPerspectiveDissolve  = 3 << 20,
    
    NaveenImageViewOptionTransitionSlideInTop        = 4 << 20,
    NaveenImageViewOptionTransitionSlideInLeft       = 5 << 20,
    NaveenImageViewOptionTransitionSlideInBottom     = 6 << 20,
    NaveenImageViewOptionTransitionSlideInRight      = 7 << 20,
    
    NaveenImageViewOptionTransitionFlipFromLeft      = 8 << 20,
    NaveenImageViewOptionTransitionFlipFromRight     = 9 << 20,
    
    NaveenImageViewOptionTransitionRipple            = 10 << 20,
    NaveenImageViewOptionTransitionCubeFromTop       = 11 << 20,
    NaveenImageViewOptionTransitionCubeFromLeft      = 12 << 20,
    NaveenImageViewOptionTransitionCubeFromBottom    = 13 << 20,
    NaveenImageViewOptionTransitionCubeFromRight     = 14 << 20,
    
};

@interface UIView (Animations)
-(void)makeImageTrasition:(UIView *)viewTemp effect :(NaveenImageViewOptions) effect;
-(CALayer*)wt_layerFromImage:(UIImage*) image viewTemp:(UIView *)viewTemp;
-(void)fadeInAnimation:(UIView *)viewTemp delay:(NSTimeInterval)delay;
@end

@interface NRAnimations : NSObject
#define LoaderImages @[@"Loader_0",@"Loader_1",@"Loader_3",@"Loader_4",@"Loader_5",@"Loader_6",@"Loader_7",@"Loader_8",@"Loader_9",@"Loader_10",@"Loader_11",@"Loader_12",@"Loader_13",@"Loader_14",@"Loader_15",@"Loader_16",@"Loader_17",@"Loader_18",@"Loader_19",@"Loader_20",@"Loader_21",@"Loader_22",@"Loader_23",@"Loader_24",@"Loader_25",@"Loader_26",@"Loader_27",@"Loader_28",@"Loader_29",@"Loader_30"]

+ (UIImageView *)animateImageViewWithImages:(NSArray *)images;
@end
