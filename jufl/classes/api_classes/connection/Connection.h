//
//  Connection.h
//  Naveen Rana Connection Class
//
//  Created by Naveen Rana


////FrameWork required
//SystemConfiguration framework
//CFNetwork framework


#import <Foundation/Foundation.h>

@interface Connection : NSObject<NSURLConnectionDelegate> {
    
    
    //Callback blocks
    void (^successCallback)(id response);
    void (^failCallback)(NSError *error);
}

+(Connection*)sharedInstance;
+(void)showInternetAlert;
+ (void)callServiceWithName:(NSString *)serviceName postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+(void)callServiceWithImages:(NSArray *)imagesArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+(void)callServiceWithImages:(NSArray *)imagesArray videos:(NSArray *)videosArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+ (void)callServiceWithImageUrlsArray:(NSArray *)imagesArray callBackBlock:(void (^)(UIImage *image,NSError *error,BOOL finished))responeBlock;
+(void)callServiceWithURL:(NSString *)url  callBackBlock:(void (^)(id response,NSError *error))responeBlock;
//only use for php debugging purpose if they need the response string
+(void)responseString:(NSURL *)url params:(NSDictionary *)params;
+(BOOL)isInternetAvailable;

+ (void)callGooglPlaceServiceWithName:(NSString *)serviceName postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock;
@end
