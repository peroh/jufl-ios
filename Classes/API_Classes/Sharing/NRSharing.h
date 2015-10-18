//
//  NRSharing.h
//  AroundAbout
//
//  Created by Naveen Rana on 15/12/14.
//  Copyright (c) 2014 Naveen Rana. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Social/Social.h>
//#import <GooglePlus/GooglePlus.h>
#import <Accounts/Accounts.h>
//#import <FacebookSDK/FacebookSDK.h>

typedef void (^GooglePlusSignIncomplete)(BOOL success);
typedef void (^GooglePlusSharingcomplete)(BOOL isShared);
typedef void (^FaceBookCompleteHandler)(NSDictionary *response);
typedef void (^TwitterCompleteHandler)(NSDictionary *response);
typedef void (^GooglePlusCompleteHandler)(NSDictionary *response);

typedef enum TwitterFriendType
{
    kFollowerTwitter,
    kFreindsTwitter
}TwitterFriendType;
@interface NRSharing : NSObject//<GPPSignInDelegate,GPPShareDelegate>
{
    GooglePlusSignIncomplete googlePlusSignIncomplete;
    GooglePlusSharingcomplete googlePlusSharingcomplete;
    FaceBookCompleteHandler _faceBookCompleteHandler;
    TwitterCompleteHandler _twitterCompleteHandler;
    GooglePlusCompleteHandler _googlePlusCompleteHandler;
    
    
    
}
@property(nonatomic,retain)ACAccountStore *facebookACAccountStore,*twitterACAccountStore;
+ (id)sharedInstance;

//FaceBook
+(void)shareOnFacebook:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler;
+(void)shareOnFacebook:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image url:(NSURL *)url completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler;
-(void)loginWithFaceBook:(FaceBookCompleteHandler)completeHandler;
-(void)postToFacebook:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image url:(NSString *)url completionHandler:(FaceBookCompleteHandler)completionHandler;
+(void)getFbProfileImageWithFbId:(NSString *)facebookID completion:(void(^)(UIImage *image))completion;
-(void)getFaceBookFriends:(FaceBookCompleteHandler)completeHandler;

//Twitter
-(void)loginWithTwitter:(TwitterCompleteHandler)completeHandler;

+(void)shareOnTwitter:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler;
+(void)shareOnTwitter:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image url:(NSURL *)url completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler;
-(void)getTwitterFollowersFriends:(TwitterFriendType)twitterFriendType  cursor:(NSString *)cursor completeHandler:(TwitterCompleteHandler)completeHandler;


//GooglePlus
/*
-(void)shareOnGooglePlus:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image  url:(NSURL*)url completionHandler:(GooglePlusSharingcomplete)completionHandler;
-(void)loginWithGooglePlus:(GooglePlusCompleteHandler)completeHandler;*/

@end
