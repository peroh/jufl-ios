//
//  ChatModel.h
//  jufl
//
//  Created by Dhirendra Kumar on 1/27/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatModel : NSObject
typedef void (^ChatBlock) (BOOL success, NSDictionary *response, NSError *error);
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *fisrtName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSDate *chatDateTime;
@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, strong) NSString *messageId;


- (instancetype)initWithChatDictionary:(NSDictionary *)dict;
+ (void)getGroupChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block;
+ (void)getPrivateChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block;
+ (void)getLatestGroupChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block;
+ (void)getLatestPrivateChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block;
+ (void)postGroupChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block;
+ (void)postPrivateChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block;
+ (void)setEventMuteUnmuteNotification:(NSDictionary *)params withSuccessBlock:(ChatBlock)block;
@end
