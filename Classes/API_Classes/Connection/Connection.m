//
//  Connection.m
///  Naveen Rana Connection Class
//
//  Created by Naveen Rana
//
//

//  Naveen Rana Connection Class
//
//  Created by Naveen Rana

//FrameWork required
//SystemConfiguration framework
//CFNetwork framework

#import "Connection.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "NRAESCrypt.h"
//#import "AFImageRequestOperation.h"
//#import "UIButton+AFNetworking.h"
#import "AFSharedClient.h"
#import "AppDelegate.h"


#define kAuthentication @"Authentication"                    //Header key of request  encrypt data
#define kEncryptionKey      @"AroundAbout"                    //Encryption key replace this with your projectname
#define kBundleVersion @"BundleVersion"




@implementation Connection

//shared instance
+(Connection*)sharedInstance
{
    static Connection* sharedObj = nil;
    if (sharedObj == nil) {
        sharedObj = [[Connection alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return sharedObj;
}
#pragma check internet connection
+(BOOL)isInternetAvailable
{
   // return [AFNetworkReachabilityManager sharedManager].reachable;

    BOOL isInternetAvailable = false;
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            isInternetAvailable = FALSE;
        }
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

#pragma mark showInternetAlert
+(void)showInternetAlert
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Connection error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark showServerErrorAlert
+(void)showServerErrorAlert
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark - callServiceWithName
+ (void)callServiceWithName:(NSString *)serviceName postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
           [Utils showToastWithMessage:kInternetConectionError];
        }];
        

        responeBlock(nil,[NSError errorWithDomain:@"internet error" code:-1 userInfo:nil]);
        return;
        
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:postData];
    
    if([UserModel userId])
    {
       // [params setObject:@4 forKey:KUserID];
        [params setObject:[UserModel userId] forKey:kUserID];
    }
    
    if([SharedClass sharedInstance].deviceId)
    {
        
        [params setObject:([SharedClass sharedInstance].deviceId) forKey:@"device_id"];
//        [params setObject:@"9BE92780-2700-4450-8A57-3E134F62BEBE" forKey:@"device_id"];
    }
 
    //[params setObject:@"4" forKey:KUserID];
    
    //[self responseString:[NSURL URLWithString:urlString] params:postData];
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    DLog(@"Request for %@/%@Parameters \n %@",baseUrl.absoluteString, serviceName,params);

    AFSharedClient *client=[AFSharedClient sharedClient];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];

    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
         manager.responseSerializer=[AFJSONResponseSerializer serializer];
        [manager.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
        
        [manager POST:serviceName parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            responeBlock(responseObject,nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            responeBlock(nil,error);
            [Utils stopActivityIndicatorInView];
            [Connection showServerErrorAlert];
        }];
    }
    else
    {
        [client.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];

        [client POST:serviceName parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            if (!success(responseObject, nil)) {
                [Utils stopActivityIndicatorInView];
                WebServiceResponse *webResponse = [[WebServiceResponse alloc]initWithData:responseObject];
                if ([webResponse.message isEqualToString:@"Unauthorized."] || [webResponse.message isEqualToString:@"Admin Has Deactivated The Account"]) {
                    [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
                    [[CoreDataConfiguration sharedInstance] clearCoreDataBase];
                    [UserDefaluts removeObjectForKey:kCurrentUserID];
                    [appDelegate setRootForApp];
                }
            }
            else {
            responeBlock(responseObject,nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            responeBlock(nil,error);

        }];
     
    }
}

+ (void)callFourSquareServiceWithName:(NSString *)serviceName postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        responeBlock(nil,[NSError errorWithDomain:@"internet error" code:-1 userInfo:nil]);
        [Connection showInternetAlert];
        return;
        
    }
    
    // NSString *urlString = [kGooglePlaceBaseURL stringByAppendingPathComponent:serviceName];
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:postData];
    
    //DLog(@"Request for URL :%@  \n Parameters \n %@",urlString,params);
    //[self responseString:[NSURL URLWithString:urlString] params:postData];
    NSURL *baseUrl=[NSURL URLWithString:kFourSquareBaseURL];
    AFSharedClient *client=[AFSharedClient sharedGoogleClient];
    // NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        manager.responseSerializer=[AFJSONResponseSerializer serializer];
        //[manager.requestSerializer setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
        //[manager.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
        [manager GET:serviceName parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            responeBlock(responseObject,nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            responeBlock(nil,error);
            //[Connection showServerErrorAlert];
        }];
        
        
    }
    else
    {
        //[client.requestSerializer setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
        //[client.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
        [client GET:serviceName parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            responeBlock(responseObject,nil);
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            responeBlock(nil,error);
            // [Connection showServerErrorAlert];
            
        }];
        
    }
}


#pragma mark - callServiceWithImages
+(void)callServiceWithImages:(NSArray *)imagesArray params:(NSDictionary *)postData  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        [Utils stopActivityIndicatorInView];
        [Utils createMainQueue:^{
            [Utils showToastWithMessage:kInternetConectionError];
        }];
        
        responeBlock(nil,[NSError errorWithDomain:@"internet error" code:-1 userInfo:nil]);
        return;
        
    }
    
  //  NSString *urlString = [kBaseURL stringByAppendingPathComponent:serviceName];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    DLog(@"Request for %@/%@Parameters \n %@",baseUrl.absoluteString, serviceName,postData);

    AFSharedClient *client=[AFSharedClient sharedClient];
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:postData];

    if([UserModel userId])
    {
        [params setObject:[UserModel userId] forKey:kUserID];
    }
    
    
    if([SharedClass sharedInstance].deviceId)
        [params setObject:[SharedClass sharedInstance].deviceId forKey:@"device_id"];
    
   
    // [params setObject:@"9BE92780-2700-4450-8A57-3E134F62BEBE" forKey:@"device_id"];
    
   // DLog(@"Request for URL :%@  \n Parameters \n %@",urlString,params);
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];

    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        manager.responseSerializer=[AFJSONResponseSerializer serializer];
        //[manager.requestSerializer setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
        [manager.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];

        [manager POST:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for(int i=0;i<[imagesArray count];i++)
            {
                NSString *fileName=[NSString stringWithFormat:@"image%d.jpg",i+1];
                NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
                
                [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
                
            }
            
            [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            responeBlock(responseObject,nil);

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            responeBlock(nil,error);
            [Connection showServerErrorAlert];
        }];
    }
    else // ios 7
    {
        //[client.requestSerializer setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
        [client.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];

        [client POST:serviceName parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for(int i=0;i<[imagesArray count];i++)
            {
                NSString *fileName=[NSString stringWithFormat:@"image%d.jpg",i+1];
                NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
                
                [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
        
            }
            
            [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            if (!success(responseObject, nil)) {
                WebServiceResponse *webResponse = [[WebServiceResponse alloc]initWithData:responseObject];
                if ([webResponse.message isEqualToString:@"Unauthorized."] || [webResponse.message isEqualToString:@"Admin Has Deactivated The Account"]) {
                    [SharedClass sharedInstance].currentEvent = [[EventModel alloc]init];
                    [[CoreDataConfiguration sharedInstance] clearCoreDataBase];
                    [UserDefaluts removeObjectForKey:kCurrentUserID];
                    [appDelegate setRootForApp];
                }
            }
            responeBlock(responseObject,nil);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            responeBlock(nil,error);
            [Connection showServerErrorAlert];
        }];
        
    }
}

#pragma mark - callServiceWith Images and Videos
//post images with data in multipart
+(void)callServiceWithImages:(NSArray *)imagesArray videos:(NSArray *)videosArray params:(NSDictionary *)postData  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
  //  NSString *urlString = [kBaseURL stringByAppendingPathComponent:serviceName];
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    AFSharedClient *client=[AFSharedClient sharedClient];
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:postData];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    DLog(@"Request for %@/%@Parameters \n %@",baseUrl.absoluteString, serviceName,params);

    if([UserModel userId])
    {
        [params setObject:[UserModel userId] forKey:kUserID];
    }
    
  //  DLog(@"Request for URL :%@  \n Parameters \n %@",urlString,params);
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        manager.responseSerializer=[AFJSONResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 180;
        //[manager.requestSerializer setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
        [manager.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];

        [manager POST:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for(int i=0;i<[imagesArray count];i++)
            {
                NSString *fileName=[NSString stringWithFormat:@"image%d.jpg",i+1];
                NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
                
                [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
                
            }
            
            for(int i=0;i<[videosArray count];i++)
            {
                NSString *fileName=[NSString stringWithFormat:@"video%d",i+1];
                NSString *videoName=[NSString stringWithFormat:@"video%d",i+1];
                
                [formData appendPartWithFileData:[videosArray objectAtIndex:i] name:videoName fileName:fileName mimeType:@"video/mp4"];
                
            }
            [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            responeBlock(responseObject,nil);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            responeBlock(nil,error);
            [Connection showServerErrorAlert];
        }];
    }
    else // ios 7
    {
       // [client.requestSerializer setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
        [client.requestSerializer setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
        client.requestSerializer.timeoutInterval = 180;

        [client POST:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for(int i=0;i<[imagesArray count];i++)
            {
                NSString *fileName=[NSString stringWithFormat:@"image%d.jpg",i+1];
                NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
                
                [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
                
            }
            
            for(int i=0;i<[videosArray count];i++)
            {
                NSString *fileName=[NSString stringWithFormat:@"video%d",i+1];
                NSString *videoName=[NSString stringWithFormat:@"video%d",i+1];
                
                [formData appendPartWithFileData:[videosArray objectAtIndex:i] name:videoName fileName:fileName mimeType:@"video/mp4"];
                
            }
            
            
            [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"Response for %@ \n%@",serviceName,responseObject);
            responeBlock(responseObject,nil);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            responeBlock(nil,error);
            [Connection showServerErrorAlert];
        }];
        
    }
}

#pragma mark Encrypt Request
+(NSString *)encryptRequestString:(NSString *)requestStr
{
    NSString *plainTextStr=[requestStr stringByAppendingString:[NSString stringWithFormat:@"_%f",[Connection getCurrentTimeStamp]]];
    NSString *encyptedStrng=[NRAESCrypt encrypt:plainTextStr password:kEncryptionKey];
    DLog(@"encyptedStrng %@",encyptedStrng);
  //  NSString *decryptedStrng=[NRAESCrypt decrypt:encyptedStrng password:kEncryptionKey];
  //  DLog(@"decryptedStrng %@",decryptedStrng);


    
    return encyptedStrng;
    
}

#pragma mark getCurrentTimeStamp
+(NSTimeInterval )getCurrentTimeStamp
{
    NSTimeInterval timeInterval=[[NSDate date] timeIntervalSince1970];
    return timeInterval;
}

#pragma mark - callService to Get Images from Urls
+ (void)callServiceWithImageUrlsArray:(NSArray *)imagesArray callBackBlock:(void (^)(UIImage *image,NSError *error,BOOL finished))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        responeBlock(nil,[NSError errorWithDomain:@"internet error" code:-1 userInfo:nil],YES);
        [Connection showInternetAlert];
        return;
        
    }

    __block NSInteger count=imagesArray.count;
    for (NSString *imageUrl in imagesArray) {
        NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *responseObject) {
            count-=1;
            DLog(@"%ld images downloaded of total %ld",(long)count,(unsigned long)imagesArray.count);
            if(count==0)
            {
                responeBlock(responseObject,nil,YES);
                
            }
            else
            {
                responeBlock(responseObject,nil,NO);
                
            }

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if(count==0)
            {
                responeBlock(nil,error,YES);
                
            }
            else
            {
                responeBlock(nil,error,NO);
                
            }
        }];
        [operation start];
    }
    
    
  }
#pragma Only Url Web service
+(void)callServiceWithURL:(NSString *)url  callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    DLog(@"Request for URL :%@  \n",url);
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DLog(@"Response for %@ \n%@",url,responseObject);
        
        responeBlock(responseObject,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        responeBlock(nil,error);
        [Connection showServerErrorAlert];
    }];
    [operation start];
}


//only use for php debugging purpose if they need the response string
+(void)responseString:(NSURL *)url params:(NSDictionary *)params
{
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
    [request setHTTPMethod:@"POST"];
    
    NSURLResponse *responseString=nil;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&responseString error:nil];
    NSString *debugStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Server error" message:debugStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
@end
