//
//  FeedModel.h
//  JUFL
//
//  Created by Ankur on 22/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedModel : NSObject

typedef void (^FeedBlock) (BOOL success, NSDictionary *response, NSError *error);

@property (nonatomic, strong) NSNumber *nextPage;
@property (nonatomic, strong) NSMutableArray *results;

- (instancetype)initWithDictionary:(NSDictionary *)params;
+ (void)getUserFeed:(NSDictionary *)params withSuccessBlock:(FeedBlock)block;
+ (void)getCurrentFeed:(NSDictionary *)params withSuccessBlock:(FeedBlock)block;
+ (void)getPastFeed:(NSDictionary *)params withSuccessBlock:(FeedBlock)block;

- (instancetype)initWithNotificationData:(NSDictionary *)params;
+ (void)getNotifications:(NSDictionary *)params withSuccessBlock:(FeedBlock)block;
@end
