//
//  ImageCropViewController.m
//  ImageCropper
//
//  Created by Rakesh Lohan on 03/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//
#import "ImageCropViewController.h"
#import "TouchView.h"
#import "ImageScrollView.h"
#import "UIImage+_FixOrientation.h"



@interface ImageCropViewController ()

#define LineWidth 2.0f

@property (strong, nonatomic) UIColor *originalNavigationControllerViewBackgroundColor;
@property (assign, nonatomic) BOOL originalNavigationControllerNavigationBarHidden;
@property (assign, nonatomic) BOOL originalStatusBarHidden;

@property (strong, nonatomic) ImageScrollView *imageScrollView;
@property (strong, nonatomic) TouchView *overlayView;
@property (strong, nonatomic) CAShapeLayer *maskLayer;
@property (strong, nonatomic) CAShapeLayer *maskLineLayer;
@property (assign, nonatomic) CGRect maskRect;
@property (strong, nonatomic) UIBezierPath *maskPath;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (assign, nonatomic) BOOL didSetupConstraints;
@property (strong, nonatomic) NSLayoutConstraint *cancelButtonBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *chooseButtonBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *imageInstructionView;
@property (weak, nonatomic) IBOutlet UIButton *gotIt;
@property (weak, nonatomic) IBOutlet UIButton *retakeImage;
@property (weak, nonatomic) IBOutlet UIButton *useImage;
@property (weak, nonatomic) IBOutlet UIImageView *tipArrowImage;

@end

@implementation ImageCropViewController

#pragma mark - Lifecycle

- (instancetype)initWithImage:(UIImage *)originalImage
{
    self = [super init];
    if (self) {
        _originalImage = originalImage;
        _cropMode = ImageCropModeCircle;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)originalImage cropMode:(ImageCropMode)cropMode
{
    self = [super init];
    if (self) {
        _originalImage = originalImage;
        _cropMode = cropMode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeView];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:self.imageScrollView];
    [self.view addSubview:self.overlayView];
    
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
}

- (void)initializeView{
    
    [self checkGotItClicked];
    [_retakeImage.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:19.0]];
    [_useImage.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:19.0]];
    _retakeImage.layer.cornerRadius = CORNER_RADIUS;
    _useImage.layer.cornerRadius = CORNER_RADIUS;
    _gotIt.layer.cornerRadius = CORNER_RADIUS;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.originalStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.originalNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.originalNavigationControllerViewBackgroundColor = self.navigationController.view.backgroundColor;
    self.navigationController.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.originalStatusBarHidden];
    [self.navigationController setNavigationBarHidden:self.originalNavigationControllerNavigationBarHidden animated:animated];
    self.navigationController.view.backgroundColor = self.originalNavigationControllerViewBackgroundColor;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateMaskRect];
    [self layoutImageScrollView];
    [self layoutOverlayView];
    [self updateMaskPath];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.imageScrollView.zoomView) {
        [self displayImage];
    }
}


#pragma mark - Custom Accessors

- (ImageScrollView *)imageScrollView
{
    if (!_imageScrollView) {
        _imageScrollView = [[ImageScrollView alloc] init];
        _imageScrollView.clipsToBounds = NO;
    }
    return _imageScrollView;
}

- (TouchView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[TouchView alloc] init];
        _overlayView.receiver = self.imageScrollView;
        [_overlayView.layer addSublayer:self.maskLayer];
        [_overlayView.layer addSublayer:self.maskLineLayer];
    }
    return _overlayView;
}

- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillRule = kCAFillRuleEvenOdd;
        _maskLayer.fillColor = self.maskLayerColor.CGColor;
    }
    return _maskLayer;
}

- (CAShapeLayer *)maskLineLayer
{
    if(!_maskLineLayer)
    {
        _maskLineLayer = [CAShapeLayer layer];
        _maskLineLayer.fillColor = nil;
        _maskLineLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        _maskLineLayer.strokeEnd = 1.0f;
    }
    return _maskLineLayer;
}

- (UIColor *)maskLayerColor
{
    if (!_maskLayerColor) {
        _maskLayerColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    }
    return _maskLayerColor;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer
{
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapGestureRecognizer.delaysTouchesEnded = NO;
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

- (void)setOriginalImage:(UIImage *)originalImage
{
    if (![_originalImage isEqual:originalImage]) {
        _originalImage = originalImage;
        if (self.isViewLoaded) {
            [self displayImage];
        }
    }
}

- (void)setMaskPath:(UIBezierPath *)maskPath
{
    if (![_maskPath isEqual:maskPath]) {
        _maskPath = maskPath;
        
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.overlayView.frame];
        [clipPath appendPath:maskPath];
        clipPath.usesEvenOddFillRule = YES;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = [CATransaction animationDuration];
        pathAnimation.timingFunction = [CATransaction animationTimingFunction];
        [self.maskLayer addAnimation:pathAnimation forKey:@"path"];
        
        self.maskLayer.path = [clipPath CGPath];
    }
}

#pragma mark - Private

- (BOOL)isPortraitInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

- (void)resetZoomScale:(BOOL)animated
{
    CGFloat zoomScale;
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) {
        zoomScale = CGRectGetHeight(self.view.bounds) / (self.originalImage.size.height*1.5);
    } else {
        zoomScale = CGRectGetWidth(self.view.bounds) / (self.originalImage.size.width*1.5);
    }
    [self.imageScrollView setZoomScale:zoomScale animated:animated];
}

- (void)resetContentOffset:(BOOL)animated
{
    CGSize boundsSize = self.imageScrollView.bounds.size;
    CGRect frameToCenter = self.imageScrollView.zoomView.frame;
    
    CGPoint contentOffset;
    if (CGRectGetWidth(frameToCenter) > boundsSize.width) {
        contentOffset.x = (CGRectGetWidth(frameToCenter) - boundsSize.width) * 0.5f;
    } else {
        contentOffset.x = 0;
    }
    if (CGRectGetHeight(frameToCenter) > boundsSize.height) {
        contentOffset.y = (CGRectGetHeight(frameToCenter) - boundsSize.height) * 0.5f;
    } else {
        contentOffset.y = 0;
    }
    
    [self.imageScrollView setContentOffset:contentOffset animated:animated];
}

- (void)displayImage
{
    if (self.originalImage) {
        [self.imageScrollView displayImage:self.originalImage];
        [self resetZoomScale:NO];
        [self resetContentOffset:NO];
    }
}

- (void)layoutImageScrollView
{
    self.imageScrollView.frame = self.maskRect;
}

- (void)layoutOverlayView
{
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 2, CGRectGetHeight(self.view.bounds) * 2);
    self.overlayView.frame = frame;
}

- (void)updateMaskRect
{
    switch (self.cropMode) {
        case ImageCropModeCircle: {
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
            
            /*
             Original Implementation
             */
            /*
             self.maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
             (viewHeight - maskSize.height) * 0.5f,
             maskSize.width,
             maskSize.height);
             */
            /*
             Customization - Sashi
             */
            self.maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                       70,
                                       maskSize.width,
                                       maskSize.height);
            
            break;
        }
        case ImageCropModeSquare: {
            CGFloat viewWidth = CGRectGetWidth(self.view.frame);
            CGFloat viewHeight = CGRectGetHeight(self.view.frame);
            
            CGFloat length;
            if ([self isPortraitInterfaceOrientation]) {
                length = MIN(viewWidth, viewHeight) - kPortraitSquareMaskRectInnerEdgeInset * 2;
            } else {
                length = MIN(viewWidth, viewHeight) - kLandscapeSquareMaskRectInnerEdgeInset * 2;
            }
            
            CGSize maskSize = CGSizeMake(length, length);
            
            self.maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                       (viewHeight - maskSize.height) * 0.5f,
                                       maskSize.width,
                                       maskSize.height);
            break;
        }
        case ImageCropModeCustom: {
            if ([self.dataSource respondsToSelector:@selector(imageCropViewControllerCustomMaskRect:)]) {
                self.maskRect = [self.dataSource imageCropViewControllerCustomMaskRect:self];
            } else {
                self.maskRect = CGRectZero;
            }
            break;
        }
    }
}

- (void)updateMaskPath
{
    switch (self.cropMode) {
        case ImageCropModeCircle: {
            if(_maskLineLayer)
            {
                CGRect rect = CGRectInset(self.maskRect, LineWidth/2, LineWidth/2);
                UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
                _maskLineLayer.path = path.CGPath;
                _maskLineLayer.lineWidth = LineWidth;
            }
            self.maskPath = [UIBezierPath bezierPathWithOvalInRect:self.maskRect];
            break;
        }
        case ImageCropModeSquare: {
            self.maskPath = [UIBezierPath bezierPathWithRect:self.maskRect];
            break;
        }
        case ImageCropModeCustom: {
            if ([self.dataSource respondsToSelector:@selector(imageCropViewControllerCustomMaskPath:)]) {
                self.maskPath = [self.dataSource imageCropViewControllerCustomMaskPath:self];
            } else {
                self.maskPath = nil;
            }
            break;
        }
    }
}

- (CGRect)cropRect
{
    CGRect cropRect = CGRectZero;
    float zoomScale = 1.0 / self.imageScrollView.zoomScale;
    
    cropRect.origin.x = self.imageScrollView.contentOffset.x * zoomScale;
    cropRect.origin.y = self.imageScrollView.contentOffset.y * zoomScale;
    cropRect.size.width = CGRectGetWidth(self.imageScrollView.bounds) * zoomScale;
    cropRect.size.height = CGRectGetHeight(self.imageScrollView.bounds) * zoomScale;
    
    CGSize imageSize = self.originalImage.size;
    CGFloat x = CGRectGetMinX(cropRect);
    CGFloat y = CGRectGetMinY(cropRect);
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    
    UIImageOrientation imageOrientation = self.originalImage.imageOrientation;
    if (imageOrientation == UIImageOrientationRight || imageOrientation == UIImageOrientationRightMirrored) {
        cropRect.origin.x = y;
        cropRect.origin.y = imageSize.width - CGRectGetWidth(cropRect) - x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationLeftMirrored) {
        cropRect.origin.x = imageSize.height - CGRectGetHeight(cropRect) - y;
        cropRect.origin.y = x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationDown || imageOrientation == UIImageOrientationDownMirrored) {
        cropRect.origin.x = imageSize.width - CGRectGetWidth(cropRect) - x;;
        cropRect.origin.y = imageSize.height - CGRectGetHeight(cropRect) - y;
    }
    
    return cropRect;
}

- (UIImage *)croppedImage:(UIImage *)image cropRect:(CGRect)cropRect
{
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1.0f orientation:image.imageOrientation];
    CGImageRelease(croppedCGImage);
    return [croppedImage fixOrientation];
}

- (void)cropImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *croppedImage = [self croppedImage:self.originalImage cropRect:[self cropRect]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(imageCropViewController:didCropImage:)]) {
                [self.delegate imageCropViewController:self didCropImage:croppedImage];
            }
        });
    });
}

- (void)cancelCrop
{
    if ([self.delegate respondsToSelector:@selector(imageCropViewControllerDidCancelCrop:)]) {
        [self.delegate imageCropViewControllerDidCancelCrop:self];
    }
}


#pragma mark - Action handling
- (IBAction)gotIt:(id)sender {
    
    [[SharedClass sharedInstance] setGotItImageCrop:YES];
    [self checkGotItClicked];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self resetZoomScale:YES];
    [self resetContentOffset:YES];
}

- (IBAction)retakeImage:(id)sender {
    
    [self cancelCrop];
}

- (IBAction)useImage:(id)sender {
    
    [self cropImage];
}

- (void)checkGotItClicked{
    
    if ([[SharedClass sharedInstance] gotItImageCrop] == YES) {
        _imageInstructionView.hidden = YES;
        _retakeImage.hidden = NO;
        _useImage.hidden = NO;
        _tipArrowImage.hidden = YES;
    }
    
    else{
        _imageInstructionView.hidden = NO;
        _retakeImage.hidden = YES;
        _useImage.hidden = YES;
        _tipArrowImage.hidden = NO;
    }
}

@end
