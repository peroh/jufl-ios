//
//  ImageCropViewController.h
//  ImageCropper
//
//  Created by Rakesh Lohan on 03/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat kPortraitCircleMaskRectInnerEdgeInset = 95.0f;
static const CGFloat kPortraitSquareMaskRectInnerEdgeInset = 20.0f;

static const CGFloat kLandscapeCircleMaskRectInnerEdgeInset = 45.0f;
static const CGFloat kLandscapeSquareMaskRectInnerEdgeInset = 45.0f;



@protocol ImageCropViewControllerDataSource;
@protocol ImageCropViewControllerDelegate;

/**
 Types of supported crop modes.
 */
typedef NS_ENUM(NSUInteger, ImageCropMode) {
    ImageCropModeCircle,
    ImageCropModeSquare,
    ImageCropModeCustom
};

@interface ImageCropViewController : UIViewController

/**
 Designated initializer. Initializes and returns a newly allocated view controller object with the specified image.
 
 @param originalImage The image for cropping.
 */
- (instancetype)initWithImage:(UIImage *)originalImage;

/**
 Initializes and returns a newly allocated view controller object with the specified image and the specified crop mode.
 
 @param originalImage The image for cropping.
 @param cropMode The mode for cropping.
 */
- (instancetype)initWithImage:(UIImage *)originalImage cropMode:(ImageCropMode)cropMode;

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 The receiver's delegate.
 
 @discussion A `ImageCropViewControllerDelegate` delegate responds to messages sent by completing / canceling crop the image in the image crop view controller.
 */
@property (weak, nonatomic) id<ImageCropViewControllerDelegate> delegate;

/**
 The receiver's data source.
 
 @discussion A `ImageCropViewControllerDataSource` data source provides a custom rect and a custom path for the mask.
 */
@property (weak, nonatomic) id<ImageCropViewControllerDataSource> dataSource;

///--------------------------
/// @name Accessing the Image
///--------------------------

/**
 The image for cropping.
 */
@property (strong, nonatomic) UIImage *originalImage;

/// -----------------------------------
/// @name Accessing the Mask Attributes
/// -----------------------------------

/**
 The color of the layer with the mask. Default value is [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f].
 */
@property (strong, nonatomic) UIColor *maskLayerColor;

/**
 The rect of the mask.
 
 @discussion Updating each time before the crop view lays out its subviews.
 */
@property (assign, readonly, nonatomic) CGRect maskRect;

/**
 The path of the mask.
 
 @discussion Updating each time before the crop view lays out its subviews.
 */
@property (strong, readonly, nonatomic) UIBezierPath *maskPath;

/// -----------------------------------
/// @name Accessing the Crop Attributes
/// -----------------------------------

/**
 The mode for cropping.
 */
@property (assign, nonatomic) ImageCropMode cropMode;

/// -------------------------------
/// @name Accessing the UI Elements
/// -------------------------------

/**
 The Cancel Button.
 */


/// -------------------------------------------
/// @name Checking of the Interface Orientation
/// -------------------------------------------

/**
 Returns a Boolean value indicating whether the user interface is currently presented in a portrait orientation.
 
 @return YES if the interface orientation is portrait, otherwise returns NO.
 */
- (BOOL)isPortraitInterfaceOrientation;

@end

/**
 The `ImageCropViewControllerDataSource` protocol is adopted by an object that provides a custom rect and a custom path for the mask.
 */
@protocol ImageCropViewControllerDataSource <NSObject>

/**
 Asks the data source a custom rect for the mask.
 
 @param controller The crop view controller object to whom a rect is provided.
 
 @return A custom rect for the mask.
 
 @discussion Only valid if `cropMode` is `ImageCropModeCustom`.
 */
- (CGRect)imageCropViewControllerCustomMaskRect:(ImageCropViewController *)controller;

/**
 Asks the data source a custom path for the mask.
 
 @param controller The crop view controller object to whom a path is provided.
 
 @return A custom path for the mask.
 
 @discussion Only valid if `cropMode` is `ImageCropModeCustom`.
 */
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(ImageCropViewController *)controller;

@end

/**
 The `ImageCropViewControllerDelegate` protocol defines messages sent to a image crop view controller delegate when crop image was canceled or the original image was cropped.
 */
@protocol ImageCropViewControllerDelegate <NSObject>

/**
 Tells the delegate that crop image has been canceled.
 */
- (void)imageCropViewControllerDidCancelCrop:(ImageCropViewController *)controller;

/**
 Tells the delegate that the original image has been cropped.
 */
- (void)imageCropViewController:(ImageCropViewController *)controller didCropImage:(UIImage *)croppedImage;



@end
