//
//  Utils.m
//  MOMCents
//
//  Created by Naveen Rana on 29/01/15.
//  Copyright (c) 2015 Appster. All rights reserved.//

#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "OLImageView.h"
#import "OLImage.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AddressBook/AddressBook.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import "NRAnimations.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "FileHandler.h"
#import "Reachability.h"
#import "Categories.h"
#import "AppDelegate.h"


//#import "AFHTTPClient.h"

@implementation Utils

+ (id)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark -
+ (void) showOKAlertWithTitle:(NSString*)aTitle message:(NSString*)aMsg
{
    
	UIAlertView	*aAlert = [[UIAlertView alloc] initWithTitle:aTitle message:aMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[aAlert show];
}
////----- show a alert massage
+ (void) showAlertView :(NSString*)title message:(NSString*)msg delegate:(id)delegate
      cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate
										  cancelButtonTitle:CbtnTitle otherButtonTitles:otherBtnTitles, nil];
	[alert show];
	
}

+ (void) showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)msg delegate:(id)delegate
            cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate
										  cancelButtonTitle:CbtnTitle otherButtonTitles:otherBtnTitles, nil];
    alert.tag = tag;
	[alert show];
	
}

#pragma mark Custom Alert
- (void)showCustomOKAlertWithMessage:(NSString*)message completionHandler:(CustomAlertCompletion)completionHandler
{
    customAlertCompletion=[completionHandler copy];
	CSAlertView *alert = [[CSAlertView alloc] initWithTitle:kTitle Body:message WithYesNO:NO];
    alert.useMotionEffects=YES;
    __weak typeof(CSAlertView) *weakAlert=alert;
    [alert setOnButtonTouchUpInside:^(CSAlertView *alertView, ButtonType buttonType) {
        [weakAlert close];
        if(customAlertCompletion)
            customAlertCompletion(alertView,buttonType);
    }];
    [alert show];
}
-(void)showCustomOKAlertWithTitle:(NSString*)aTitle message:(NSString*)message buttonTitle:(NSString *)buttonTitle completionHandler:(CustomAlertCompletion)completionHandler
{
    customAlertCompletion=[completionHandler copy];

	CSAlertView *alert = [[CSAlertView alloc] initWithTitle:kTitle Body:message WithYesNO:NO];
    [alert.btnOk setTitle:buttonTitle forState:alert.btnOk.state];
    alert.useMotionEffects=YES;
     __weak typeof(CSAlertView) *weakAlert=alert;
    [alert setOnButtonTouchUpInside:^(CSAlertView *alertView, ButtonType buttonType) {
        [weakAlert close];
        if(customAlertCompletion)
            customAlertCompletion(alertView,buttonType);
    }];
    [alert show];
}

-(void)showCustomOKCancelAlertWithMessage:(NSString*)message completionHandler:(CustomAlertCompletion)completionHandler
{
    customAlertCompletion=[completionHandler copy];
	CSAlertView *alert = [[CSAlertView alloc] initWithTitle:kTitle Body:message WithYesNO:YES];
    alert.useMotionEffects=YES;
    __weak typeof(CSAlertView) *weakAlert=alert;
    [alert setOnButtonTouchUpInside:^(CSAlertView *alertView, ButtonType buttonType) {
        [weakAlert close];
        if(customAlertCompletion)
            customAlertCompletion(alertView,buttonType);


    }];
    [alert show];
}

-(void)showCustomOKCancelAlertWithMessage:(NSString*)aTitle message:(NSString*)message buttonTitleOK:(NSString *)buttonTitleOK buttonTitleCancel:(NSString *)buttonTitleCancel completionHandler:(CustomAlertCompletion)completionHandler
{
    customAlertCompletion=[completionHandler copy];
	CSAlertView *alert = [[CSAlertView alloc] initWithTitle:kTitle Body:message WithYesNO:NO];
    [alert.btnOk setTitle:buttonTitleOK forState:alert.btnOk.state];
    [alert.btnCancel setTitle:buttonTitleCancel forState:alert.btnCancel.state];
    alert.useMotionEffects=YES;
    __weak typeof(CSAlertView) *weakAlert=alert;
    [alert setOnButtonTouchUpInside:^(CSAlertView *alertView, ButtonType buttonType) {
        [weakAlert close];
        if(customAlertCompletion)
            customAlertCompletion(alertView,buttonType);
    }];
    [alert show];
}

#pragma mark - Activity Indicator
+(void)startActivityIndicatorWithMessage:(NSString*)aMessage
{
    [[self class] startAnimationActivityIndicatorInView:appDelegate.window];
    return;
        MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
        _hud.dimBackground = YES;
        _hud.labelText = aMessage;
}

+ (void)startAnimationActivityIndicatorInView:(UIView*)view
{
    [Utils createMainQueue:^{
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        HUD.dimBackground = YES;
        HUD.color=[UIColor clearColor];
        HUD.mode=MBProgressHUDModeCustomView;
        
        //Position the explosion image view somewhere in the middle of your current view. In my case, I want it to take the whole view.Try to make the png to mach the view size, don't stretch it
        
       // OLImageView *imageView = [[OLImageView alloc] initWithImage:[OLImage imageNamed:@"loading.gif"]];
        //Add images which will be used for the animation using an array. Here I have created an array on the fly
        //_explosion.animationImages =  @[[UIImage imageNamed:@"GB.png"],[UIImage imageNamed:@"microphone.png"]];
        NSArray *imagesArray = @[@"Loader_0",@"Loader_1",@"Loader_3",@"Loader_4",@"Loader_5"];
        UIImageView *animatedImageView = [NRAnimations animateImageViewWithImages:imagesArray];
        animatedImageView.backgroundColor=[UIColor clearColor];
        //Set the duration of the entire animation
        //imageView.animationDuration = 0.5;
        
        //Set the repeat count. If you don't set that value, by default will be a loop (infinite)
        //_explosion.animationRepeatCount = 1;
        
        //Start the animationrepeatcount
        //[imageView startAnimating];
        HUD.customView=animatedImageView;
    }];
	
}

+(void)stopActivityIndicatorInView
{
    [Utils createMainQueue:^{
        [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];

    }];
}

#pragma mark Show Toast
+(void)showToastWithMessage:(NSString *)message
{
    [appDelegate.window makeToast:message duration:1.5 position:PositionTop];

}
+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -<Download Image>
+(void)downloadImage:(NSString *)imageUrl completion:(void(^)(UIImage *image))block
{
    [Utils createBackGroundQueue:^{
        _Block_H_ NSData *data =nil;
        data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        //[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                DLog(@"Image Downloaded");
                block(image);
            }
            else
            {
                DLog(@"Image Downloaded Failed");
                block(kPlaceHolderPlaceImage);
            }
        });
    }];
                      /*
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
    dispatch_async(queue, ^{
    
        _Block_H_ NSData *data =nil;
        data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        //[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                DLog(@"Image Downloaded");
                block(image);
            }
            else
            {
                DLog(@"Image Downloaded Failed");
                UIImage *imgPlaceholder = [UIImage imageNamed:@"imgPlaceholderM.png"];
                block(imgPlaceholder);
            }
        });
    });*/
}

+(UIImage *)getImageForUrl:(NSString *)imageUrl
{
    imageUrl=[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *imageData=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    if(!imageData)
        return nil;
    UIImage *image=[UIImage imageWithData:imageData];
    imageData=nil;
    return image;
    
}

+ (BOOL)removeSpaces:(NSString *)str
{
    if([str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        return NO;
    }
    else{
        return  YES;
    }
}

+ (NSUInteger)stringLength:(NSString *)str
{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return str.length;
}
#pragma mark - email validation
+(BOOL) IsValidEmail:(NSString *)emailString Strict:(BOOL)strictFilter
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = strictFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

#pragma mark - create label
+(UILabel*)createLabel:(NSString*)text withFrame:(CGRect)frame backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor textFont:(NSString*)fontName fontSize:
(float)fontSize textAlign:(NSTextAlignment)align numberOfLines:(int)numLines
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    [lbl setText:text];
    [lbl setBackgroundColor:backgroundColor];
    [lbl setTextColor:textColor];
    [lbl setTextAlignment:align];
    lbl.numberOfLines = numLines;
    [lbl setFont:[UIFont fontWithName:fontName size:fontSize]];
    return lbl;
}


#pragma mark - create image
+(UIImageView*)createImagewithFrame:(CGRect)frame withImageName:(NSString*)imgName
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    [imgView setImage:[UIImage imageNamed:imgName]];
    return imgView;
}

#pragma mark - Save NSUserDefault
+ (void)saveNSUserDefaultforKey:(NSString*)key withValue:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark GENERATE THUMB IMAGE
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image ResolutionMax:(int)kMaxRes
{
	int kMaxResolution = kMaxRes;
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution)
    {
        CGFloat ratio = width/height;
        if (ratio > 1)
        {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient)
	{
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			break;
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
	{
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else
	{
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
	
}

#pragma mark - Animation Block

+ (void) animationMoveInFromRightToLeft:(UIView*)myView
{
    CATransition *transition2 = [CATransition animation];
	transition2.duration = 1.0;
	transition2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition2.type    = kCATransitionPush;
	transition2.subtype = kCATransitionFromRight;
	//BOOL transitioning = NO;
	[myView.layer addAnimation:transition2 forKey:nil];
}

+ (void) animationMoveInFromLeftToRight:(UIView*)myView
{
    CATransition *transition2 = [CATransition animation];
	transition2.duration = 1.0;
	transition2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition2.type    = kCATransitionPush;
	transition2.subtype = kCATransitionFromLeft;
	//BOOL transitioning = NO;
	[myView.layer addAnimation:transition2 forKey:nil];
}


#pragma mark UIButton

+ (UIButton *)newButtonWithTarget:(id)target  selector:(SEL)selector frame:(CGRect)frame image:(UIImage *)image selectedImage:(UIImage *)selectedImage	  tag:(NSInteger)aTag
{
	//UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom] ;
	button.frame = frame;
	[button setImage:image forState:UIControlStateNormal];
	[button setImage:selectedImage forState:UIControlStateSelected];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	button.showsTouchWhenHighlighted = YES;
	button.tag = aTag;
	return button ;
}
#pragma mark Crop image from View
+(UIImage *)getImageFromView:(UIView *)view InRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *contextImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([contextImage CGImage], rect);
    
    UIImage *finalImage=[UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    
    return finalImage;
}

#pragma mark UIImagePickerController with Block
-(void)openImagePickerController:(UIImagePickerControllerSourceType)sourceType isVideo:(BOOL)isVideo inViewController:(UIViewController *)viewController completion:(void(^)(UIImagePickerController *controller,NSDictionary * info))completeBlock  cancel:(void(^)(void))cancelBlock;
{
    self.imagePickerControllerCompletionBlock=completeBlock;
    self.imagePickerControllerCancelBlock=cancelBlock;
    UIImagePickerController *controller=[[UIImagePickerController alloc] init];
    controller.delegate=self;
    controller.allowsEditing=NO;
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        controller.sourceType=sourceType;
        
        switch (sourceType) {
                
            case UIImagePickerControllerSourceTypeCamera:
            {
                if(isVideo)
                {
                    controller.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
                    // Hides the controls for moving & scaling pictures, or for
                    // trimming movies. To instead show the controls, use YES.
                    controller.allowsEditing = YES;
                    controller.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo ;
                    [controller setVideoMaximumDuration:30];
                }
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                
            }
                break;
            case UIImagePickerControllerSourceTypePhotoLibrary:
            {
                //                if(isFromAdPost)
                //                {
                //                    controller.allowsEditing = YES;
                //
                //                }
            }
                
            default:
                break;
        }
        if(!viewController)
        {
            [Utils showOKAlertWithTitle:kTitle message:@"Please pass viewController"];
            return;
        }
        [viewController presentViewController:controller animated:YES completion:nil];
        
    }
    else
    {
        [Utils showOKAlertWithTitle:kTitle message:@"Not support on this device"];
    }
    
}
//imagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        if(self.imagePickerControllerCompletionBlock)
            self.imagePickerControllerCompletionBlock(picker,info);
        
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if(self.imagePickerControllerCancelBlock)
            self.imagePickerControllerCancelBlock();
        
    }];
}

#pragma mark AlertView with Block
-(void)openAlertViewUserNameWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons completion:(void(^)(UIAlertView *alert,NSInteger buttonIndex))alertBlock
{
    self.alertCompletionBlock=alertBlock;
    //NSString *buttonTitles=[buttons componentsJoinedByString:@","];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    
    UITextField* tf = [alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeEmailAddress;
    
    for(NSString *buttonTitle in buttons)
    {
        [alert addButtonWithTitle:buttonTitle];
    }
    // Configured for MiVista -- to show prefilled text in Alert text field//
    if([NRValidation isValidString:message])
    {
        alert.alertViewStyle=UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].text= message;
        
    }

    [alert show];
}

-(void)openAlertViewWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons completion:(void(^)(UIAlertView *alert,NSInteger buttonIndex))alertBlock
{
    self.alertCompletionBlock=alertBlock;
    //NSString *buttonTitles=[buttons componentsJoinedByString:@","];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    for(NSString *buttonTitle in buttons)
    {
        [alert addButtonWithTitle:buttonTitle];
    }
    [alert show];
}
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{    
    if(self.alertCompletionBlock)
        self.alertCompletionBlock(alertView,buttonIndex);
}


#pragma mark UIActionSheet with Block
-(void)openActionSheetWithTitle:(NSString *)title buttons:(NSArray *)buttons completion:(void(^)(UIActionSheet *actionSheet,NSInteger buttonIndex))actionSheetBlock
{
    self.actionSheetCompletionBlock=actionSheetBlock;
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    //actionSheet.actionSheetStyle=UIActionSheetStyleDefault;
    for(NSString *buttonTitle in buttons)
    {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex=actionSheet.numberOfButtons-1;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // DLog(@"second");
        
        if(self.actionSheetCompletionBlock)
            self.actionSheetCompletionBlock(actionSheet,buttonIndex);
        
    });
    
    // DLog(@"first");
}


#pragma mark Mail composer
-(void)openMailComposerInViewController:(UIViewController *)viewController subject:(NSString *)subject attachment:(NSData *)attachment completeionHandler:(MailComposerCompletionHandler)mailCompletionHandler
{
    _mailComposerCompletionHandler=[mailCompletionHandler copy];
    MFMailComposeViewController *composer=[[MFMailComposeViewController alloc]init];
    [composer setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        //[composer setToRecipients:[NSArray arrayWithObjects:@"xyz@gmail.com", nil]];
        [composer setSubject:@""];
        [composer setMessageBody:subject isHTML:NO];
        [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        if(attachment)
            [composer addAttachmentData:attachment mimeType:@"image/jpeg" fileName:@"Product.jpg"];
        [viewController presentViewController:composer animated:YES completion:nil];
    }
    else {
        [Utils showOKAlertWithTitle:kTitle message:@"Please configure your mail account"];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",[error description]] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
        [alert show];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [controller dismissViewControllerAnimated:YES completion:^{
            _mailComposerCompletionHandler(result,nil);
        }];
    }
}

#pragma mark Time
+(NSString *)getCurrentTime
{
    //"CommentDate":"9/24/2013 2:20:02 PM"
    NSString *dateFormat=@"MM/dd/YYYY hh:mm:ss a";
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    return [formatter stringFromDate:[NSDate date]];
}

+(NSString *)getCurrentTimeinHHMM
{
    //"CommentDate":"9/24/2013 2:20:02 PM"
    NSString *dateFormat=@"hh:mm a";
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    return [formatter stringFromDate:[NSDate date]];
}
//Returns current UTC time
+(NSString *)getUTCTimeCurrent
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: [NSDate date]];
    NSDate *dt =  [NSDate dateWithTimeInterval: seconds sinceDate: [NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSString *str = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dt]];
    
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date=[dateFormatter dateFromString:str];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:date];
}

+(NSString *)getLocalTimeFromUtc :(NSString*)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date=[dateFormatter dateFromString:str];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:date];
    
}

+(NSString *)getLocalTimeFromUtc:(NSString*)dateStr inFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:format];

    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:date];
    
}

+(NSString *)differenceFromCurrentTime:(NSString *)dateStr
{
    NSString *localDate=[Utils getLocalTimeFromUtc:dateStr];
    NSDate *date=[Utils dateFromStr:localDate];
    
    ////// get total seconds
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Get conversion to seconds
    unsigned int unitFlags = NSCalendarUnitSecond;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date  toDate:[NSDate date]  options:0];
    
    NSInteger totalSeconds = [breakdownInfo second];
    
    //DLog(@"Break down: %d seconds ", [breakdownInfo second]);
    if(totalSeconds < 60)
    {
        if (totalSeconds == 1)
        {
            return [NSString stringWithFormat:@"%ld sec ago",(long)totalSeconds];
        }
        else
        {
            return [NSString stringWithFormat:@"%ld secs ago",(long)totalSeconds];
        }
    }
    else if( totalSeconds >= 60 && totalSeconds <3600)
    {
        NSInteger min = totalSeconds/60;
        if (min == 1)
        {
            return [NSString stringWithFormat:@"%ld min ago",(long)min];
        }
        else
        {
            return [NSString stringWithFormat:@"%ld mins ago",(long)min];
        }
    }
    else if( totalSeconds >= 3660 && totalSeconds <86400)
    {
        NSInteger hour = totalSeconds/3600;
        if (hour == 1)
        {
            return [NSString stringWithFormat:@"%ld hour ago",(long)hour];
        }
        else
        {
            return [NSString stringWithFormat:@"%ld hours ago",(long)hour];
        }
    }
    else if(totalSeconds >= 86400 && totalSeconds <= 259200)
    {
        int secondsInAMinute = 60;
        int secondsInAnHour  = 60 * secondsInAMinute;
        int secondsInADay    = 24 * secondsInAnHour;
        
        NSInteger days = totalSeconds / secondsInADay;
        
        //int hourSeconds = totalSeconds % secondsInADay;
        //int hours = hourSeconds / secondsInAnHour;
        
        //int minuteSeconds = hourSeconds % secondsInAnHour;
        //int minutes = minuteSeconds / secondsInAMinute;
        
        //int remainingSeconds = minuteSeconds % secondsInAMinute;
        if (days == 1)
        {
            return [NSString stringWithFormat:@"%ld day ago",(long)days];
        }
        else
        {
            return [NSString stringWithFormat:@"%ld days ago",(long)days];
        }
    }
    else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMMM d, yyyy"];
        NSString *dateStr = [df stringFromDate:date];
        return dateStr;
    }
    
}

+ (NSDate *)dateFromStr:(NSString *)dateStr
{
    NSString *dateFormat=@"MM/dd/yyyy hh:mm:ss a";
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    // [formatter setDateStyle:NSDateFormatterFullStyle];
    //[formatter setTimeZone:[NSTimeZone systemTimeZone]];
    // [formatter setLocale:[NSLocale currentLocale]];
    return [formatter dateFromString:dateStr];
}

+ (NSDate *)dateFromStr:(NSString *)dateStr withFormat:(NSString *)format
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateStr];
}



+(NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format{
    NSDateFormatter *prefixDateFormatter = [[NSDateFormatter alloc] init];
    [prefixDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [prefixDateFormatter setDateFormat:format];//June 13th, 2013
    NSString * prefixDateString = [prefixDateFormatter stringFromDate:date];
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setDateFormat:@"d"];
    int date_day = [[monthDayFormatter stringFromDate:date] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    
    prefixDateString = [prefixDateString stringByReplacingOccurrencesOfString:@"." withString:suffix];
    NSString *dateString =prefixDateString;
    
    
   
     DLog(@"%@", dateString);
    return dateString;
}

+ (NSString *)formatedDateFromString: (NSString*)string{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:string];
    [dateFormatter setDateFormat:@"MMM dd, yyyy - HH:mm"];
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:date];
}


//Showcase
+(NSString *)getLocalTimeFromUtc2 :(NSString*)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date=[dateFormatter dateFromString:str];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:date];
    
}

+ (NSDate *)dateFromStr2:(NSString *)dateStr
{
    NSString *dateFormat=@"MM/dd/yyyy";
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    // [formatter setDateStyle:NSDateFormatterFullStyle];
    //[formatter setTimeZone:[NSTimeZone systemTimeZone]];
    // [formatter setLocale:[NSLocale currentLocale]];
    return [formatter dateFromString:dateStr];
}

+(NSString *)formatDateAndTimeShowcase:(NSString *)dateStr
{
    NSArray *arr = [dateStr componentsSeparatedByString:@" "];
    dateStr = [arr objectAtIndex:0];
    
    NSString *localDate=[Utils getLocalTimeFromUtc2:dateStr];
    NSDate *date=[Utils dateFromStr2:localDate];
    
    ////// get total seconds
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Get conversion to seconds
    unsigned int unitFlags = NSCalendarUnitSecond;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date  toDate:[NSDate date]  options:0];
    
    NSInteger totalSeconds = [breakdownInfo second];
    if (totalSeconds < 86400)
    {
        return  [NSString stringWithFormat:@"Today %@ at ",[arr objectAtIndex:1]];
    }
    else if(totalSeconds > 86400 && totalSeconds < 172800)
    {
        return  [NSString stringWithFormat:@"Tomorrow %@ at ",[arr objectAtIndex:1]];
    }
    else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMMM d, yyyy"];
        NSString *dateStr = [df stringFromDate:date];
        return dateStr;
    }
    return dateStr;
}

#pragma mark Address Book Contacts
+ (void)addressBookRecord:(NSMutableArray *)appEmailsArray completion:(void(^)(NSMutableArray * resultArray))resultBlock
{

    CFErrorRef myError = NULL;
    ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, &myError);
    ABAddressBookRequestAccessWithCompletion(myAddressBook,
                                             ^(bool granted, CFErrorRef error) {
                                                 if (granted) {
                                                     NSMutableArray *finalRecordsArray=[[NSMutableArray alloc] init];

                                                     CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(myAddressBook);
                                                     for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
                                                         NSMutableDictionary *addressBookDict=[[NSMutableDictionary alloc] init];
                                                         
                                                         ABRecordRef person = CFArrayGetValueAtIndex(people, i);
                                                         ABMultiValueRef emailsArray = ABRecordCopyValue(person, kABPersonEmailProperty);
                                                         ABMultiValueRef phoneNumbersArray = ABRecordCopyValue(person, kABPersonPhoneProperty);
                                                         NSString *email=nil;
                                                         NSString *phoneNumber=nil;
                                                         if(ABMultiValueGetCount(emailsArray)>0)
                                                         {
                                                             email=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(emailsArray, 0));
                                                             if([appEmailsArray containsObject:email])
                                                                 continue;
                                                         }
                                                         else
                                                         {
                                                             email=@"";
                                                         }
                                                         (ABMultiValueGetCount(phoneNumbersArray)>0)?(phoneNumber=(__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbersArray, 0)):(phoneNumber=@"");
                                                         NSString *firstName=(__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                                                         NSString *lastName=(__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                                                         (firstName==NULL)?(firstName=@""):(firstName);
                                                         (lastName==NULL)?(lastName=@""):(lastName);
                                                         
                                                         NSString *fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                                                         
                                                         if(([email length]==0)&&([phoneNumber length]==0))
                                                             continue;
                                                         
                                                         [addressBookDict setObject:email forKey:@"email"];
                                                         [addressBookDict setObject:phoneNumber forKey:@"phone"];
                                                         [addressBookDict setObject:fullName forKey:@"name"];
                                                         
                                                         
                                                         [finalRecordsArray addObject:addressBookDict];
                                                         addressBookDict=nil;
                                                         CFRelease(emailsArray);
                                                     }
                                                     resultBlock(finalRecordsArray);
                                                     CFRelease(people);
                                                  
                                                 } else {
                                                     // Handle the case of being denied access and/or the error.
                                                     [Utils showOKAlertWithTitle:kTitle message:@"You should allow acces to contacts to your app!"];
                                                 }
                                                 CFRelease(myAddressBook);
                                             });

    
}

+ (void)addressBookEmailRecordsWithCompletion:(void(^)(NSMutableArray * resultArray))resultBlock
{
    CFErrorRef myError = NULL;
    ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, &myError);
    ABAddressBookRequestAccessWithCompletion(myAddressBook,
                                             ^(bool granted, CFErrorRef error) {
                                                 if (granted) {
                                                     NSMutableArray *allEmailsArray=[NSMutableArray array];
                                                     CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(myAddressBook);

                                                     for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
                                                         ABRecordRef person = CFArrayGetValueAtIndex(people, i);
                                                         ABMultiValueRef emailsArray = ABRecordCopyValue(person, kABPersonEmailProperty);
                                                         NSString *email=nil;
                                                         (ABMultiValueGetCount(emailsArray)>0)?(email=(__bridge NSString*)ABMultiValueCopyValueAtIndex(emailsArray, 0)):(email=nil);
                                                         if(email)
                                                             [allEmailsArray addObject:email];
                                                         
                                                         CFRelease(emailsArray);
                                                     }
                                                     resultBlock(allEmailsArray);
                                                     CFRelease(people);
                                                     
                                                 } else {
                                                     // Handle the case of being denied access and/or the error.
                                                     [Utils showOKAlertWithTitle:kTitle message:@"You should allow acces to contacts to your app!"];
                                                 }
                                                 CFRelease(myAddressBook);
                                             });

}

+(BOOL)isInternetAvailable
{
    BOOL isInternetAvailable = false;
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            isInternetAvailable = FALSE;
            break;
        case ReachableViaWWAN:
            isInternetAvailable = TRUE;
            break;
        case ReachableViaWiFi:
            isInternetAvailable = TRUE;
            break;
    }
    [internetReach stopNotifier];
    return isInternetAvailable;
}


+(void)makeImageCircular:(UIImageView *)image withradius:(int)radius
{
    [image setContentMode:UIViewContentModeScaleAspectFill];
    image.layer.cornerRadius = radius;
    image.layer.masksToBounds = YES;
    image.layer.borderWidth = 2;
    image.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
}

+(void)makeImageCircular:(UIImageView *)imageView
{
    [imageView setContentMode:UIViewContentModeScaleToFill];
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 2;
    imageView.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
}

+(UIImage *)generateThumbNailOfVideo:(NSURL *)videoUrl
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(2, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumbImage;
}
+ (NSString*)checkDeviceType:(NSString*)className
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        //return [NSString stringWithFormat:@"%@_iPad",className];
        return [NSString stringWithFormat:@"%@",className];
    }
    else if ([UIScreen mainScreen].bounds.size.height == 480.0f)
    {
        return [NSString stringWithFormat:@"%@",className];
    }
    else
    {
        return [NSString stringWithFormat:@"%@_iPhone5",className];
    }
}

+(void)setCornerRadiusofView:(UIView *)view
{
    [view.layer setCornerRadius:2.0];
    [view.layer setBorderColor:[UIColor clearColor].CGColor];
    [view.layer setBorderWidth:0.0];
    //[view.layer setShadowColor:[UIColor lightGrayColor].CGColor];
}

-(void)addNavigationBarInView:(UIView *)view withTitle:(NSString *)title backbuttonCompletionHandler:(void(^)(id sender))buttonBlock
{
    
    self.backButtonBlock=[buttonBlock copy];
    UIView *navView=(UIView *)[[[NSBundle mainBundle] loadNibNamed:@"BackView" owner:nil options:nil] objectAtIndex:0];
    navView.tag=54321;
    CGRect frame=navView.frame;
    frame.origin.x=0;
    
    /*if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        frame.origin.y=0;
    }
    else
    {
        frame.origin.y=20;
    }*/
    //navView.backgroundColor=kIconGreenColor;
    navView.frame=frame;
    UILabel *titleLabel=(UILabel *)[navView viewWithTag:1];
    titleLabel.text=title;
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17]];
    //UIButton *backButton=(UIButton *)[navView viewWithTag:2];
    //[backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:navView];
       
}

+(void)addRightNavBarButtonWithTitle:(NSString *)title action:(SEL)action inView:(UIViewController *)viewController
{
   /* UIView *navView=[viewController.view viewWithTag:kNavViewTag];
    UIButton *button=(UIButton *)[navView viewWithTag:5];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];*/

}


#pragma mark Animate TextField
+(void)animateUpTextField:(UITextField *)textField inView:(UIView *)view
{
    [UIView animateWithDuration:0.2 animations:^{
        if ((textField.frame.origin.y+textField.frame.size.height)>(view.frame.size.height-216)) {
            if([view isKindOfClass:[UIScrollView class]])
            {
                CGPoint point=view.center;
                point.x=0;
                point.y-=200;
                [(UIScrollView *)view setContentOffset:point];
            }
            else
            {
                [view setTransform:CGAffineTransformMakeTranslation(0, -130)];
            }
        }
        
    } completion:nil];
    /*[UIView animateWithDuration:0.2 animations:^{
        if (textField.frame.origin.y>(view.frame.size.height/2-20)) {
            [view setTransform:CGAffineTransformMakeTranslation(0, -130)];
        }
        
    } completion:nil];*/
}
+(void)animateDownTextField:(UITextField *)textField inView:(UIView *)view
{
    [UIView animateWithDuration:0.2 animations:^{
        [view setTransform:CGAffineTransformMakeTranslation(0, 0)];
    } completion:nil];
    
}
+(void)animateTextField:(UITextField*)textField up:(BOOL)up inView:(UIView *)view
{
    if(!up&&view.frame.origin.y==0)
        return;
    int movementDistance = -130; // tweak as needed
    if(textField.tag==356)
        movementDistance=-200;
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    view.frame = CGRectOffset(view.frame, 0, movement);
    [UIView commitAnimations];
}
+(void)animateTextView:(UITextView*)textView up:(BOOL)up inView:(UIView *)view
{
    if(!up&&view.frame.origin.y==0)
        return;
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    view.frame = CGRectOffset(view.frame, 0, movement);
    [UIView commitAnimations];
}

+(void)animateViewFieldToRect:(UIView *)rectView inView:(UIView *)view up:(BOOL)up
{
    if(!up&&view.frame.origin.y==0)
        return;

    CGRect rect=[rectView convertRect:rectView.bounds toView:view];
   // const int movementDistance = -200; // tweak as needed
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat distance=-200;
        int movement = (up ? distance : -distance);
        if(up)
        {
            if(rect.origin.y>(view.frame.size.height-216)) // under keyboard
            {
                distance=rect.origin.y-(view.frame.size.height-216); //distance to move
                view.frame = CGRectOffset(view.frame, 0, -distance);
                
            }
            else
            {
                //view.frame=view.window.frame;
                view.frame = CGRectOffset(view.frame, 0, movement);
            }


        }
        
        else
        {
            //view.frame=view.window.frame;
            view.frame = CGRectOffset(view.frame, 0, movement);
        }

    } completion:nil];
}




+ (void)playMovie:(NSString*)videoStr viewController:(UIViewController*)vc
{
    BOOL isLocalVideoUrl=YES;
    if([videoStr isKindOfClass:[NSString class]])
        isLocalVideoUrl=NO;
    
    if(!isLocalVideoUrl)
        videoStr=[videoStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MPMoviePlayerViewController *mp = nil;
    mp = [[MPMoviePlayerViewController alloc] init];
    mp.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    
    //    [[NSNotificationCenter defaultCenter] addObserver:vc
    //                                             selector:@selector(moviePlayBackDidFinish:)name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    
    mp.moviePlayer.view.frame = CGRectMake(0, 0, vc.view.bounds.size.width, vc.view.bounds.size.height);
    
    mp.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    
    mp.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [vc presentMoviePlayerViewControllerAnimated:mp];
    
    
    
   // videoStr = [videoStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *movieUrl = nil;
    if(isLocalVideoUrl)
    {
        movieUrl=(NSURL *)videoStr;
    }
    else
    {
        movieUrl=[NSURL URLWithString:videoStr];
    }
    [mp.moviePlayer setContentURL:movieUrl];
    [mp.moviePlayer prepareToPlay];
    [mp.moviePlayer play];
}

+(void)showImageFullScreen:(UIViewController*)viewController isFromAdPost:(BOOL)isFromAdPost arrayImages:(NSMutableArray*)arrayImages selectedImage:(int)selectedImage
{
    /*ImageDetailViewController *imageDetailViewController = [viewController.storyboard instantiateViewControllerWithIdentifier:@"ImageDetailViewController"];
    imageDetailViewController.selectedImageNo = selectedImage;
    imageDetailViewController.isFromAdPost = isFromAdPost;
    imageDetailViewController.arrayImages = arrayImages;
    [viewController.navigationController pushViewController:imageDetailViewController animated:YES];*/
    
}
+(void)popViewController:(UIViewController*)vc popViewController:(UIViewController*)popViewController
{
    NSArray *arr = vc.navigationController.viewControllers;
    for (UIViewController *popVC in arr) {
        if([popVC isKindOfClass:[popViewController class]])
        {
            [vc.navigationController popToViewController:popVC animated:YES];
            break;
        }
    }
}



+(void)showUserProfile:(NSString*)userID viewController:(UIViewController*)vc
{
    /*if ([userID isEqualToString:[UserDefaluts objectForKey:kUserID]]) {
        MyProfileViewController *viewController=[vc.storyboard instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
        [vc.navigationController pushViewController:viewController animated:YES];
           }
    else
    {
        UserProfileViewController *userProfileViewController = [vc.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        userProfileViewController.userID = userID;
        
        [vc.navigationController pushViewController:userProfileViewController animated:YES];
  
    }*/
   
}


+ (UIImage*) blur:(UIImage*)theImage
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:4] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
    // if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}


#pragma mark - Image Resize
+ (UIImage *)scaleImage:(UIImage *)sourceImage maxWidth:(int) maxWidth maxHeight:(int) maxHeight
{
   
    CGFloat targetWidth = maxWidth;
    CGFloat targetHeight = maxHeight;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);
	
    if (width <= maxWidth && height <= maxHeight)
	{
		return sourceImage;
	}

    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGBitmapByteOrderDefault;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    UIImage* newImage=nil;
    if(bitmap)
    {
        CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
        CGImageRef ref = CGBitmapContextCreateImage(bitmap);
        newImage = [UIImage imageWithCGImage:ref];
        CGContextRelease(bitmap);
        CGImageRelease(ref);

    }
    else
    {
        return [Utils imageWithImage:sourceImage scaledToSize:CGSizeMake(maxWidth, maxHeight)];
    }
    return newImage;

    
   /* CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    if (width <= maxWidth && height <= maxHeight)
	{
		return image;
	}
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    bounds.size.width = maxWidth;
    bounds.size.height = maxHeight;
	
    if (width > maxWidth || height > maxHeight)
	{
		CGFloat ratio = width/height;
		
		if (ratio > 1)
		{
			bounds.size.width = maxWidth;
			bounds.size.height = bounds.size.width / ratio;
		}
		else
		{
			bounds.size.height = maxHeight;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
    CGFloat scaleRatio = bounds.size.width / width;
    //CGFloat scaleRatio = 1.0;
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);
    CGContextTranslateCTM(context, 0, -height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
	
    return imageCopy;*/
	
}

//createBackGroundQueue
+(void)createBackGroundQueue:(void(^)(void))block
{
    dispatch_queue_t backGroundQueue=dispatch_queue_create("backGroundQueue", NULL);
    dispatch_async(backGroundQueue, ^{
        block();
    });
}
+(void)createMainQueue:(void(^)(void))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        block();
    });
}

+(void)createMainSyncQueue:(void(^)(void))block
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        block();
    });
}

#pragma mark Add Images on Scroll View
+(void)addImagesOnScrollView:(UIScrollView *)scrollView imagesArray:(NSArray *)imagesArray
{
    scrollView.pagingEnabled=YES;
    CGFloat x=0;
    CGFloat y=0;
    for(UIImage *image in imagesArray)
    {
        CGRect imageViewFrame;
        
        imageViewFrame= CGRectMake(x,y,320,scrollView.frame.size.height);
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:imageViewFrame];
        [imageView setImage:image];
        [scrollView addSubview:imageView];
        x+=320;
        [scrollView setContentSize:CGSizeMake(x, y)];
    }
   
}

#pragma save image in user folder
+(void)saveImage:(UIImage *)image userID:(NSString *)userID completeionHandler:(void(^)(NSString *imagePath))completeionBlock
{
    [Utils createBackGroundQueue:^{
        NSInteger indexofimage=0;
        NSArray *allImagesArray=[FileHandler getAllDirContents:[NSString stringWithFormat:@"%@/%@",@"Folder",userID]];
        if([allImagesArray count]>0)
        {
            indexofimage=[allImagesArray indexOfObject:[allImagesArray lastObject]];
            indexofimage+=1;
        }
        NSString *finalImagePAth=[NSString stringWithFormat:@"%@/%@/Image%ld.jpg",@"Folder",userID,(long)indexofimage];
        [FileHandler saveImageToDocDir:image withFileName:finalImagePAth];
        [Utils createMainQueue:^{
            completeionBlock(finalImagePAth);
        }];
    }];
}
#pragma mark Get Json String for Dictionary
+(NSString *)getJsonStringForDictionary:(NSDictionary *)dictionary
{
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonStr=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

+(void)getImageFromDocumentDirectoryForIndexPath:(NSIndexPath *)indexPath imagepath:(NSString *)imagePath completionHander:(void(^)(UIImage *image, NSIndexPath *indexPath))block
{

    [Utils createBackGroundQueue:^{
        UIImage *image=[UIImage imageWithContentsOfFile:[DOCUMENT_DIRECTORY stringByAppendingPathComponent:imagePath]];
        [Utils createMainQueue:^{
            block(image,indexPath);
            
        }];

    }];
   
}

#pragma mark Get File Data from Bundle
+(id)getFileDataFromBundle:(NSString *)fileName type:(NSString *)type
{
    id jsonStr=[[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSData *jsonData=[NSData dataWithContentsOfFile:jsonStr];
    id jsonObject=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return jsonObject;
}


#pragma mark Play Push Notificattion Sound 
+(void)playAlertSound
{
    double delayInSeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        AudioServicesPlaySystemSound(1002);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //sleep(2);
        //AudioServicesDisposeSystemSoundID(1002);
    });
    
}
+(void)vibrateDevice
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}


#pragma mark Map Zoom
/*
+(void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate mapView:(MKMapView *)mapView
{
    [UIView animateWithDuration:3 animations:^{
        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(coordinate,1000, 1000);
        MKCoordinateSpan span;
        span.latitudeDelta=0.1f*10;
        span.longitudeDelta=0.1f*10;
        
        region.span=span;
        region.center = coordinate;
        [mapView setRegion:region animated:YES];
        [mapView regionThatFits:region];
    }];
    
}
//centre to annotation
+(void)moveMapToCoordinate:(MKMapView *)mapView annotation:(MapViewAnnonation *)annotation
{
    [UIView animateWithDuration:.5 animations:^{
        [mapView setCenterCoordinate:annotation.coordinate];
        
    }];
   
}
+(void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate mapView:(MKMapView *)mapView zoomLevel:(NSUInteger)zoomLevel
{
    [UIView animateWithDuration:3 animations:^{
        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(coordinate,1000, 1000);
        MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, zoomLevel)*mapView.frame.size.width/256);
        region.span=span;
        region.center = coordinate;
        [mapView setRegion:region animated:YES];
        [mapView regionThatFits:region];
    }];
    
}*/
+(void)setScrollViewPosition:(UIScrollView *)scrollView inView:(UIView *)view
{
    CGPoint point=view.center;
    point.x=0;
    point.y-=200;
    [scrollView setContentOffset:point animated:YES];
    
}


#pragma mark Add Tap Gesture
+(void)addTapGestureInView:(UIView *)view viewController:(UIViewController *)viewController action:(SEL)action
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:viewController action:action];
    gestureRecognizer.numberOfTapsRequired = 1;
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:gestureRecognizer];
}
+(void)addTapGestureWithTwoTapsInView:(UIView *)view viewController:(UIViewController *)viewController action:(SEL)action
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:viewController action:action];
    gestureRecognizer.numberOfTapsRequired = 2;
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:gestureRecognizer];
}


#pragma mark Exclude Icloud backup
+(void)dontSaveBackUponIcloudForBackUpDir:(NSString *)directoryname
{
    NSString *urlStr=[FileHandler filePathFromDocuments:directoryname];
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:urlStr]];
    
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        
        DLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
    
}
#pragma mark 
+(NSString *)imageNameFromImageUrl:(NSString *)imageUrl
{
    NSArray *resultArray=[imageUrl componentsSeparatedByString:@"/"];
    return [resultArray lastObject];
}

#pragma mark Play youtube video
+ (void)playYoutubeMovie:(NSURL*)movieUrl viewController:(UIViewController*)vc
{
    MPMoviePlayerViewController *mp = nil;
    mp = [[MPMoviePlayerViewController alloc] init];
    mp.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    
    
    mp.moviePlayer.view.frame = CGRectMake(0, 0, vc.view.bounds.size.width, vc.view.bounds.size.height);
    
    mp.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    
    mp.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [vc presentMoviePlayerViewControllerAnimated:mp];
    [mp.moviePlayer setContentURL:movieUrl];
    [mp.moviePlayer prepareToPlay];
    [mp.moviePlayer play];
}

#pragma Images
+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (NSInteger )calculateUserAge:(NSInteger)year
{
    NSDate *currentDate = [NSDate date];
    return currentDate.year - year;
}

@end
