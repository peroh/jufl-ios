//
//  Utils.h
//  MOMCents
//
//  Created by Naveen Rana on 29/01/15.
//  Copyright (c) 2015 Appster. All rights reserved.


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "CSAlertView.h"


typedef void (^MailComposerCompletionHandler)(MFMailComposeResult result,NSError *error);
typedef void(^CustomAlertCompletion)(CSAlertView *alertView, ButtonType buttonType);


@interface Utils : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    MailComposerCompletionHandler _mailComposerCompletionHandler;
    CustomAlertCompletion customAlertCompletion;
}



@property(nonatomic,copy) void(^alertCompletionBlock)(UIAlertView *alert ,NSInteger index);
@property(nonatomic,copy) void (^imagePickerControllerCompletionBlock)(UIImagePickerController *controller,NSDictionary * info);
@property(nonatomic,copy) void (^imagePickerControllerCancelBlock)();
@property(nonatomic,copy) void(^actionSheetCompletionBlock)(UIActionSheet *actionSheet ,NSInteger index);
@property(nonatomic,copy)void(^backButtonBlock)(id sender);

+ (void) showAlertView :(NSString*)title message:(NSString*)msg delegate:(id)delegate
      cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles;
+ (void) showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)msg delegate:(id)delegate
            cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles;
+(void)startActivityIndicatorWithMessage:(NSString*)aMessage;
+ (void)stopActivityIndicatorInView;
+ (void)downloadImage:(NSString *)imageUrl completion:(void(^)(UIImage *image))block;
+ (BOOL)isInternetAvailable;
+ (BOOL)removeSpaces:(NSString *)str;
+ (NSUInteger)stringLength:(NSString *)str;
+ (BOOL) IsValidEmail:(NSString *)emailString Strict:(BOOL)strictFilter;

+ (void)saveNSUserDefaultforKey:(NSString*)key withValue:(NSString*)value;
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image ResolutionMax:(int)kMaxRes;
+ (void) animationMoveInFromRightToLeft:(UIView*)myView;
+ (void) animationMoveInFromLeftToRight:(UIView*)myView;

//naveen methods
-(void)openImagePickerController:(UIImagePickerControllerSourceType)sourceType isVideo:(BOOL)isVideo inViewController:(UIViewController *)viewController completion:(void(^)(UIImagePickerController *controller,NSDictionary * info))completeBlock  cancel:(void(^)(void))cancelBlock;
+ (id)sharedInstance;
-(void)openAlertViewWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons completion:(void(^)(UIAlertView *alert,NSInteger buttonIndex))alertBlock;
-(void)openAlertViewUserNameWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons completion:(void(^)(UIAlertView *alert,NSInteger buttonIndex))alertBlock;
-(void)openMailComposerInViewController:(UIViewController *)viewController subject:(NSString *)subject attachment:(NSData *)attachment completeionHandler:(MailComposerCompletionHandler)mailCompletionHandler;
-(void)openActionSheetWithTitle:(NSString *)title buttons:(NSArray *)buttons completion:(void(^)(UIActionSheet *actionSheet,NSInteger buttonIndex))actionSheetBlock;
+ (void) showOKAlertWithTitle:(NSString*)aTitle message:(NSString*)aMsg;
+(NSString *)getCurrentTime;
+(NSString *)getUTCTimeCurrent;
+(NSString *)getCurrentTimeinHHMM;
+(NSString *)getLocalTimeFromUtc:(NSString*)dateStr inFormat:(NSString *)format;
+ (NSDate *)dateFromStr:(NSString *)dateStr withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format;



+(UIImage *)getImageFromView:(UIView *)view InRect:(CGRect)rect;
+(NSString *)getLocalTimeFromUtc :(NSString*)str;
+(NSString *)differenceFromCurrentTime:(NSString *)dateStr;
+(NSDate *)dateFromStr:(NSString *)dateStr;
+(NSString *)formatDateAndTimeShowcase:(NSString *)dateStr;

+ (NSString *)formatedDateFromString: (NSString*)string;

+ (void)addressBookRecord:(NSMutableArray *)appEmailsArray completion:(void(^)(NSMutableArray * resultArray))resultBlock;
+ (void)addressBookEmailRecordsWithCompletion:(void(^)(NSMutableArray * resultArray))resultBlock;

+(void)makeImageCircular:(UIImageView *)image withradius:(int)radius;
+(UIImage *)generateThumbNailOfVideo:(NSURL *)videoUrl;
+ (NSString*)checkDeviceType:(NSString*)className;
+(void)setCornerRadiusofView:(UIView *)view;
-(void)addNavigationBarInView:(UIView *)view withTitle:(NSString *)title backbuttonCompletionHandler:(void(^)(id sender))buttonBlock;
+(void)animateUpTextField:(UITextField *)textField inView:(UIView *)view;
+(void)animateDownTextField:(UITextField *)textField inView:(UIView *)view;
+ (void)playMovie:(NSString*)videoStr viewController:(UIViewController*)vc;
+ (void)playYoutubeMovie:(NSURL*)movieUrl viewController:(UIViewController*)vc;

+(void)popViewController:(UIViewController*)vc popViewController:(UIViewController*)popViewController;
+(UIImage *)getImageForUrl:(NSString *)imageUrl;
+(void)showImageFullScreen:(UIViewController*)viewController isFromAdPost:(BOOL)isFromAdPost arrayImages:(NSMutableArray*)arrayImages selectedImage:(int)selectedImage;
+(void)showUserProfile:(NSString*)userID viewController:(UIViewController*)vc;
+ (UIImage*) blur:(UIImage*)theImage;
+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(int) maxWidth maxHeight:(int) maxHeight;
+(void)createBackGroundQueue:(void(^)(void))block;
+(void)createMainQueue:(void(^)(void))block;
+(void)createMainSyncQueue:(void(^)(void))block;
+(void)addImagesOnScrollView:(UIScrollView *)scrollView imagesArray:(NSArray *)imagesArray;
+(void)saveImage:(UIImage *)image userID:(NSString *)userID completeionHandler:(void(^)(NSString *imagePath))completeionBlock;
+(void)makeImageCircular:(UIImageView *)imageView;
+(NSString *)getJsonStringForDictionary:(NSDictionary *)dictionary;
+(void)getImageFromDocumentDirectoryForIndexPath:(NSIndexPath *)indexPath imagepath:(NSString *)imagePath completionHander:(void(^)(UIImage *image, NSIndexPath *indexPath))block;
//+(void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate mapView:(MKMapView *)mapView zoomLevel:(NSUInteger)zoomLevel;
//+(void)moveMapToCoordinate:(MKMapView *)mapView annotation:(MapViewAnnonation *)annotation;

+(id)getFileDataFromBundle:(NSString *)fileName type:(NSString *)type;
+(void)playAlertSound;
+(void)setScrollViewPosition:(UIScrollView *)scrollView inView:(UIView *)view;
+(void)animateTextField:(UITextField*)textField up:(BOOL)up inView:(UIView *)view;
+(void)animateTextView:(UITextView*)textView up:(BOOL)up inView:(UIView *)view;


+(void)addTapGestureInView:(UIView *)view viewController:(UIViewController *)viewController action:(SEL)action;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
+(void)dontSaveBackUponIcloudForBackUpDir:(NSString *)directoryname;
+ (UIImage *)imageWithView:(UIView *)view;
+(void)vibrateDevice;
+ (void)startAnimationActivityIndicatorInView:(UIView*)view;

#pragma mark Custom Alert
- (void)showCustomOKAlertWithMessage:(NSString*)message completionHandler:(CustomAlertCompletion)completionHandler;
-(void)showCustomOKAlertWithTitle:(NSString*)aTitle message:(NSString*)message buttonTitle:(NSString *)buttonTitle completionHandler:(CustomAlertCompletion)completionHandler;
-(void)showCustomOKCancelAlertWithMessage:(NSString*)message completionHandler:(CustomAlertCompletion)completionHandler;
-(void)showCustomOKCancelAlertWithMessage:(NSString*)aTitle message:(NSString*)message buttonTitleOK:(NSString *)buttonTitleOK buttonTitleCancel:(NSString *)buttonTitleCancel completionHandler:(CustomAlertCompletion)completionHandler;
+(void)addTapGestureWithTwoTapsInView:(UIView *)view viewController:(UIViewController *)viewController action:(SEL)action;

#pragma mark Show Toast
+(void)showToastWithMessage:(NSString *)message;

+ (NSInteger )calculateUserAge:(NSInteger)year;

@end
