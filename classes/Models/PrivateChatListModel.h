//
//  PrivateChatListModel.h
//  jufl
//
//  Created by Dhirendra Kumar on 1/27/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrivateChatListModel : NSObject
typedef void (^ChatListBlock) (BOOL success, NSDictionary *response, NSError *error);

@property (nonatomic, strong) NSNumber *fromUserId;
@property (nonatomic, strong) NSNumber *toUserId;
@property (nonatomic, strong) NSString *fisrtName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSNumber *unreadMsgCount;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *eventId;


- (instancetype)initWithChatListDictionary:(NSDictionary *)dict;
+ (void)getChatListData:(NSDictionary *)params withSuccessBlock:(ChatListBlock)block;
@end
