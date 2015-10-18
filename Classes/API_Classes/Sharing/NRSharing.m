//
//  NRSharing.m
//  RefreshControlTest
//
//  Created by Naveen Rana on 03/04/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//

#import "NRSharing.h"
//#import <GoogleOpenSource/GoogleOpenSource.h>

@implementation NRSharing

static NSString * const kGoogleClientId = @"758654860278-60atcjk0f37nkmb7lh6lh4g61tie67b3.apps.googleusercontent.com";
#define kFaceBookAppID  @"1433455960279286"

#define kFacebookSettingsMessage @"You can't login right now, make sure your device has an internet connection Also Please check your Facebook account settings via \nSettings->Facebook"
#pragma mark Shared Instance
+ (id)sharedInstance
{
    //[FBSettings setDefaultAppID:kFaceBookAppID];
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Social Sharing
#pragma mark  Facebook
+(void)shareOnFacebook:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler
{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbPost = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *shareStatus=[NSString stringWithFormat:@"%@",status];
        [fbPost setInitialText:shareStatus];
        [fbPost addImage:image];
        // block will be called on, so we need to ensure that any UI updates occur
        // on the main queue
        fbPost.completionHandler=completionHandler;
        
        [viewController presentViewController:fbPost animated:YES completion:nil];
    }
    else
    {
        [Utils showOKAlertWithTitle:@"Sorry" message:@"You can't send a post right now, make sure your device has an internet connection and you have at least one Facebook account setup"];
    }
}


-(void)loginWithFaceBook:(FaceBookCompleteHandler)completeHandler
{
    _faceBookCompleteHandler=[completeHandler copy];
    self.facebookACAccountStore = [[ACAccountStore alloc] init];
    NSArray *permissionsArray = [[NSArray alloc] initWithObjects:
                                 @"user_relationships",
                                 @"user_birthday",
                                 @"email",
                                 @"user_friends",
                                 @"user_relationship_details",
                                 nil];
    
    ACAccountType *facebookTypeAccount = [self.facebookACAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [self.facebookACAccountStore requestAccessToAccountsWithType:facebookTypeAccount
                                                         options:@{ACFacebookAppIdKey: kFaceBookAppID, ACFacebookPermissionsKey:permissionsArray,ACFacebookAudienceKey : ACFacebookAudienceEveryone}
                                                      completion:^(BOOL granted, NSError *error) {
                                                          if(granted){
                                                              NSArray *accounts = [self.facebookACAccountStore accountsWithAccountType:facebookTypeAccount];
                                                              if(accounts.count==0)
                                                              {
                                                                  
                                                                  [Utils createMainQueue:^{
                                                                      _faceBookCompleteHandler(nil);
                                                                      
                                                                      [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                                  }];
                                                                  return ;
                                                              }
                                                              ACAccount *faceBookAccount=[accounts objectAtIndex:0];
                                                              DLog(@"Success");
                                                              NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
                                                                                                                            SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                                        requestMethod:SLRequestMethodGET
                                                                                                                  URL:meurl
                                                                                                           parameters:nil];
                                                              
                                                              merequest.account = faceBookAccount;
                                                              
                                                              [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                  //NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                                  
                                                                  //DLog(@"%@", meDataString);
                                                                  [Utils createMainQueue:^{
                                                                      if(error)
                                                                      {
                                                                          _faceBookCompleteHandler(nil);
                                                                          
                                                                          [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                                      }
                                                                      else
                                                                      {
                                                                          NSDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                                                                          _faceBookCompleteHandler(jsonDict);
                                                                          DLog(@"facebook info :  %@",jsonDict);
                                                                      }
                                                                      
                                                                  }];
                                                                  
                                                                  
                                                              }];
                                                              
                                                              
                                                          }else{
                                                              // ouch
                                                              [Utils createMainQueue:^{
                                                                  _faceBookCompleteHandler(nil);
                                                                  
                                                                  [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                              }];
                                                              
                                                              
                                                              DLog(@"Fail");
                                                              DLog(@"Error: %@", error);
                                                          }
                                                      }];
    
}


-(void)getFaceBookFriends:(FaceBookCompleteHandler)completeHandler
{
    _faceBookCompleteHandler=[completeHandler copy];
    self.facebookACAccountStore = [[ACAccountStore alloc] init];
    NSArray *permissionsArray = [[NSArray alloc] initWithObjects:
                                 @"read_friendlists",
                                 @"email",
                                 nil];
    
    ACAccountType *facebookTypeAccount = [self.facebookACAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [self.facebookACAccountStore requestAccessToAccountsWithType:facebookTypeAccount
                                                         options:@{ACFacebookAppIdKey: kFaceBookAppID, ACFacebookPermissionsKey:permissionsArray,ACFacebookAudienceKey : ACFacebookAudienceEveryone}
                                                      completion:^(BOOL granted, NSError *error) {
                                                          if(granted){
                                                              NSArray *accounts = [self.facebookACAccountStore accountsWithAccountType:facebookTypeAccount];
                                                              if(accounts.count==0)
                                                              {
                                                                  
                                                                  [Utils createMainQueue:^{
                                                                      _faceBookCompleteHandler(nil);
                                                                      
                                                                      [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                                  }];
                                                                  return ;
                                                              }
                                                              ACAccount *faceBookAccount=[accounts objectAtIndex:0];
                                                              DLog(@"Success");
                                                              //NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
                                                              NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me/taggable_friends"];
                                                              
                                                              
                                                              // NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/862924897069339/friendlists"];
                                                              
                                                              
                                                              NSString *acessToken = [NSString stringWithFormat:@"%@",faceBookAccount.credential.oauthToken];
                                                              // NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:@"picture,id,name,installed",@"fields",acessToken,@"access_token", nil];
                                                              
                                                              NSDictionary *parameters = @{@"access_token": acessToken};
                                                              SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                                        requestMethod:SLRequestMethodGET
                                                                                                                  URL:meurl
                                                                                                           parameters:parameters];
                                                              
                                                              merequest.account = faceBookAccount;
                                                              
                                                              [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                  //NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                                  
                                                                  //DLog(@"%@", meDataString);
                                                                  [Utils createMainQueue:^{
                                                                      if(error)
                                                                      {
                                                                          _faceBookCompleteHandler(nil);
                                                                          
                                                                          [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                                      }
                                                                      else
                                                                      {
                                                                          NSDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                                                                          _faceBookCompleteHandler(jsonDict);
                                                                          DLog(@"facebook info :  %@",jsonDict);
                                                                      }
                                                                      
                                                                  }];
                                                                  
                                                                  
                                                              }];
                                                              
                                                              
                                                          }else{
                                                              // ouch
                                                              [Utils createMainQueue:^{
                                                                  _faceBookCompleteHandler(nil);
                                                                  
                                                                  [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                              }];
                                                              
                                                              
                                                              DLog(@"Fail");
                                                              DLog(@"Error: %@", error);
                                                          }
                                                      }];
    
}

+(void)shareOnFacebook:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image url:(NSURL *)url completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbPost = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *shareStatus=[NSString stringWithFormat:@"%@",status];
        
        [fbPost setInitialText:shareStatus];
        [fbPost addImage:image];
        [fbPost addURL:url];
        // block will be called on, so we need to ensure that any UI updates occur
        // on the main queue
        fbPost.completionHandler=completionHandler;
        
        [viewController presentViewController:fbPost animated:YES completion:nil];
    }
    else
    {
        [Utils showOKAlertWithTitle:@"Sorry" message:@"You can't send a post right now, make sure your device has an internet connection and you have at least one Facebook account setup"];
    }
}



-(void)postToFacebook:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image url:(NSString *)url completionHandler:(FaceBookCompleteHandler)completionHandler
{
    _faceBookCompleteHandler=[completionHandler copy];
    
    self.facebookACAccountStore = [[ACAccountStore alloc] init];
    NSArray *permissionsArray = [[NSArray alloc] initWithObjects:
                                 @"publish_stream",
                                 @"user_birthday",
                                 @"email",
                                 nil];
    
    ACAccountType *facebookTypeAccount = [self.facebookACAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [self.facebookACAccountStore requestAccessToAccountsWithType:facebookTypeAccount
                                                         options:@{ACFacebookAppIdKey: kFaceBookAppID, ACFacebookPermissionsKey:permissionsArray,ACFacebookAudienceKey : ACFacebookAudienceEveryone}
                                                      completion:^(BOOL granted, NSError *error) {
                                                          if(granted){
                                                              NSArray *accounts = [self.facebookACAccountStore accountsWithAccountType:facebookTypeAccount];
                                                              if(accounts.count==0)
                                                              {
                                                                  
                                                                  [Utils createMainQueue:^{
                                                                      _faceBookCompleteHandler(nil);
                                                                      
                                                                      [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                                  }];
                                                                  return ;
                                                              }
                                                              NSString *finalStatus=status;
                                                              NSMutableDictionary *params=[@{}mutableCopy];
                                                              if(image&&url)//cant post link and image at a same time
                                                              {
                                                                  finalStatus=[NSString stringWithFormat:@"%@     %@",status,url];
                                                                  
                                                                  params=[@{@"message": finalStatus}mutableCopy];
                                                              }
                                                              else
                                                              {
                                                                  params=[@{@"message": finalStatus,@"link":url}mutableCopy];
                                                                  
                                                              }
                                                              
                                                              
                                                              ACAccount *faceBookAccount=[accounts objectAtIndex:0];
                                                              DLog(@"Success");
                                                              NSURL *requestUrl = nil;
                                                              if(image)
                                                              {
                                                                  requestUrl=[NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
                                                                  
                                                              }
                                                              else
                                                              {
                                                                  requestUrl=[NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
                                                                  
                                                              }
                                                              
                                                              /*  NSString *link = @"http://developer.apple.com/library/ios/#documentation/Social/Reference/Social_Framework/_index.html%23//apple_ref/doc/uid/TP40012233";
                                                               NSString *message = @"Testing Social Framework";
                                                               NSString *picture = @"http://www.stuarticus.com/wp-content/uploads/2012/08/SDKsmall.png";
                                                               NSString *name = @"Social Framework";
                                                               NSString *caption = @"Reference Documentation";
                                                               NSString *description = @"The Social framework lets you integrate your app with supported social networking services. On iOS and OS X, this framework provides a template for creating HTTP requests. On iOS only, the Social framework provides a generalized interface for posting requests on behalf of the user.";*/
                                                              SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                                      requestMethod:SLRequestMethodPOST
                                                                                                                URL:requestUrl
                                                                                                         parameters:params];
                                                              if(image)
                                                              {
                                                                  [request addMultipartData: UIImagePNGRepresentation(image)
                                                                                   withName:@"source"
                                                                                       type:@"multipart/form-data"
                                                                                   filename:@"FbImage"];
                                                              }
                                                              
                                                              request.account = faceBookAccount;
                                                              
                                                              [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                  
                                                                  //NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                                  
                                                                  //DLog(@"%@", meDataString);
                                                                  [Utils createMainQueue:^{
                                                                      if(error)
                                                                      {
                                                                          _faceBookCompleteHandler(nil);
                                                                          
                                                                          [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                                      }
                                                                      else
                                                                      {
                                                                          NSDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                                                                          _faceBookCompleteHandler(jsonDict);
                                                                          DLog(@"facebook info :  %@",jsonDict);
                                                                          
                                                                      }
                                                                      
                                                                  }];
                                                                  
                                                                  
                                                              }];
                                                              
                                                              
                                                          }else{
                                                              [Utils createMainQueue:^{
                                                                  _faceBookCompleteHandler(nil);
                                                                  
                                                                  [Utils showOKAlertWithTitle:@"Sorry" message:kFacebookSettingsMessage];
                                                              }];
                                                              
                                                              
                                                              DLog(@"Fail");
                                                              DLog(@"Error: %@", error);
                                                          }
                                                      }];
    
}

+(void)getFbProfileImageWithFbId:(NSString *)facebookID completion:(void(^)(UIImage *image))completion
{
    NSString *urlStr=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",facebookID];
    [Connection callServiceWithImageUrlsArray:[@[urlStr] mutableCopy] callBackBlock:^(UIImage *image, NSError *error, BOOL finished) {
        completion(image);
    }];
}

#pragma mark  Twitter
+(void)shareOnTwitter:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@",NULLVALUE(status)]];
        [tweetSheet addImage:image];
        tweetSheet.completionHandler=completionHandler;
        [viewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        [Utils showOKAlertWithTitle:kTitle message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"];
    }
}
-(void)loginWithTwitter:(TwitterCompleteHandler)completeHandler
{
    _twitterCompleteHandler=[completeHandler copy];
    self.twitterACAccountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *twitterTypeAccount = [self.twitterACAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.twitterACAccountStore requestAccessToAccountsWithType:twitterTypeAccount
                                                        options:nil
                                                     completion:^(BOOL granted, NSError *error) {
                                                         if(granted){
                                                             NSArray *accounts = [self.twitterACAccountStore accountsWithAccountType:twitterTypeAccount];
                                                             if(accounts.count==0)
                                                             {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     _twitterCompleteHandler(nil);
                                                                     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't login right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                     [alert show];
                                                                 });
                                                                 
                                                                 return ;
                                                             }
                                                             ACAccount *twitterAccount=[accounts objectAtIndex:0];
                                                             DLog(@"Success");
                                                             //NSURL *meurl = [NSURL URLWithString:@"http://api.twitter.com/1.1/users/show.json"];
                                                             NSURL *meurl = [NSURL URLWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
                                                             
                                                             //NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"screen_name",nil];
                                                             
                                                             SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                                       requestMethod:SLRequestMethodGET
                                                                                                                 URL:meurl
                                                                                                          parameters:nil];
                                                             
                                                             merequest.account = twitterAccount;
                                                             
                                                             [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                 //NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                                 
                                                                 //DLog(@"%@", meDataString);
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     if(error)
                                                                     {
                                                                         _twitterCompleteHandler(nil);
                                                                         UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't login right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                         [alert show];
                                                                         
                                                                     }
                                                                     else
                                                                     {
                                                                         NSDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                                                                         _twitterCompleteHandler(jsonDict);
                                                                         DLog(@"twitter info :  %@",jsonDict);
                                                                     }
                                                                     
                                                                 });
                                                                 
                                                                 
                                                                 
                                                                 
                                                             }];
                                                             
                                                             
                                                         }else{
                                                             // ouch
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 _twitterCompleteHandler(nil);
                                                                 UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't login right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                 [alert show];
                                                             });
                                                             
                                                             
                                                             
                                                             DLog(@"Fail");
                                                             DLog(@"Error: %@", error);
                                                         }
                                                     }];
    
}

+(void)shareOnTwitter:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image url:(NSURL *)url completionHandler:(SLComposeViewControllerCompletionHandler)completionHandler
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@",NULLVALUE(status)]];
        [tweetSheet addImage:image];
        [tweetSheet addURL:url];
        tweetSheet.completionHandler=completionHandler;
        [viewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        [Utils showOKAlertWithTitle:kTitle message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"];
    }
}
-(void)getTwitterFollowersFriends:(TwitterFriendType)twitterFriendType  cursor:(NSString *)cursor completeHandler:(TwitterCompleteHandler)completeHandler
{
    _twitterCompleteHandler=[completeHandler copy];
    self.twitterACAccountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *twitterTypeAccount = [self.twitterACAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.twitterACAccountStore requestAccessToAccountsWithType:twitterTypeAccount
                                                        options:nil
                                                     completion:^(BOOL granted, NSError *error) {
                                                         if(granted){
                                                             NSArray *accounts = [self.twitterACAccountStore accountsWithAccountType:twitterTypeAccount];
                                                             if(accounts.count==0)
                                                             {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     _twitterCompleteHandler(nil);
                                                                     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't login right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                     [alert show];
                                                                 });
                                                                 
                                                                 return ;
                                                             }
                                                             ACAccount *twitterAccount=[accounts objectAtIndex:0];
                                                             NSString *userID = [NSString stringWithFormat:@"%@",[twitterAccount valueForKeyPath:@"properties.user_id"]];
                                                             DLog(@"Success");;
                                                             
                                                             NSURL *meurl = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
                                                             if(twitterTypeAccount==kFollowerTwitter)
                                                             {
                                                                 meurl = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
                                                             }
                                                             NSDictionary *parameters = @{@"user_id" : userID,@"count":@"200",@"cursor":cursor};
                                                             //NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"screen_name",nil];
                                                             
                                                             SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                                       requestMethod:SLRequestMethodGET
                                                                                                                 URL:meurl
                                                                                                          parameters:parameters];
                                                             
                                                             merequest.account = twitterAccount;
                                                             
                                                             [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                                 //NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                                 
                                                                 //DLog(@"%@", meDataString);
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     if(error)
                                                                     {
                                                                         _twitterCompleteHandler(nil);
                                                                         UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't login right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                         [alert show];
                                                                         
                                                                     }
                                                                     else
                                                                     {
                                                                         NSDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                                                                         _twitterCompleteHandler(jsonDict);
                                                                         DLog(@"twitter info :  %@",jsonDict);
                                                                     }
                                                                     
                                                                 });
                                                                 
                                                                 
                                                                 
                                                                 
                                                             }];
                                                             
                                                             
                                                         }else{
                                                             // ouch
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 _twitterCompleteHandler(nil);
                                                                 UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't login right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                 [alert show];
                                                             });
                                                             
                                                             
                                                             
                                                             DLog(@"Fail");
                                                             DLog(@"Error: %@", error);
                                                         }
                                                     }];
}
#pragma mark  GooglePlus
/*
-(void)loginWithGooglePlus:(GooglePlusCompleteHandler)completeHandler
{
    _googlePlusCompleteHandler=[completeHandler copy];
    [self googleLogin:^(BOOL success) {
        if(success)
        {
            GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
            plusService.retryEnabled = YES;
            [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
            // GTLQueryPlus *query =
            // [GTLQueryPlus queryForPeopleListWithUserId:@"me"
            //collection:kGTLPlusCollectionVisible];
            GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
            [plusService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                if (error) {
                    GTMLoggerError(@"Error: %@", error);
                    _googlePlusCompleteHandler(nil);
                    [Utils showOKAlertWithTitle:kTitle message:@"Please check your google plus settings"];
                } else {
                    // Get an array of people from GTLPlusPeopleFeed
                    //NSArray* peopleList = [peopleFeed.items retain];
                    GTLPlusPerson *person=[object copy];
                    NSDictionary *resultDict=@{@"email": NULLVALUE([GPPSignIn sharedInstance].authentication.userEmail),@"id":NULLVALUE(person.identifier),@"Username":[person.name.givenName stringByAppendingFormat:@" %@",person.name.familyName],@"imageUrl":NULLVALUE(person.image.url)};
                    _googlePlusCompleteHandler(resultDict);
                    person=nil;
                    
                }
                
            }];
 
//             [plusService executeQuery:query
//             completionHandler:^(GTLServiceTicket *ticket,
//             GTLPlusPeopleFeed *peopleFeed,
//             NSError *error) {
//             if (error) {
//             GTMLoggerError(@"Error: %@", error);
//             _googlePlusCompleteHandler(nil);
//             [Utils showOKAlertWithTitle:kTitle message:@"Please check your google plus settings"];
//             } else {
//              Get an array of people from GTLPlusPeopleFeed
//             NSArray* peopleList = [peopleFeed.items retain];
//             _googlePlusCompleteHandler(peopleFeed);
//             }
//             }];
 
        }
        else
        {
            _googlePlusCompleteHandler(nil);
        }
    }];
    
}
-(void)shareOnGooglePlus:(UIViewController *)viewController status:(NSString *)status image:(UIImage *)image  url:(NSURL*)url completionHandler:(GooglePlusSharingcomplete)completionHandler
{
    googlePlusSharingcomplete=[completionHandler copy];
    [self googleLogin:^(BOOL success) {
        if(success)
        {
            id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
            googlePlusSharingcomplete=[completionHandler copy];
            
            // This line will fill out the title, description, and thumbnail from
            // the URL that you are sharing and includes a link to that URL.
            //[shareBuilder setTitle:kTitle description:status thumbnailURL:nil];
            // [shareBuilder setContentDeepLinkID:kGoogleClientId];
            [shareBuilder setPrefillText:status];
            [shareBuilder attachImage:image];
            if(url)
                [shareBuilder setURLToShare:url];
            [shareBuilder open];
            
        }
    }];
    
}
-(void)finishedSharing:(BOOL)shared
{
    DLog(@"finished sharing");
    if(googlePlusSharingcomplete)
        googlePlusSharingcomplete(shared);
    
    
}

-(void)googleLogin:(GooglePlusSignIncomplete)completeBlock
{
    googlePlusSignIncomplete=[completeBlock copy];
    [GPPSignIn sharedInstance].clientID=kGoogleClientId;
    if([[GPPSignIn sharedInstance] authentication])
    {
        DLog(@"Already Login");
        if(googlePlusSignIncomplete)
            googlePlusSignIncomplete(YES);
    }
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [GPPShare sharedInstance].delegate=self;
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kGoogleClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin,kGTLAuthScopePlusMe ];  // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    [signIn authenticate];
}
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth

                   error: (NSError *) error{
    if(!error)
    {
        if(googlePlusSignIncomplete)
            googlePlusSignIncomplete(YES);
    }
    else
    {
        DLog(@"Received error %@ and auth object %@",error, auth);
        if(googlePlusSignIncomplete)
            googlePlusSignIncomplete(NO);
        [Utils showOKAlertWithTitle:kTitle message:@"Please check your google plus settings"];
        
    }
}
*/
@end
