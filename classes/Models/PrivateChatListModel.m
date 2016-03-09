//
//  PrivateChatListModel.m
//  jufl
//
//  Created by Dhirendra Kumar on 1/27/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import "PrivateChatListModel.h"
NSString *const kUserId = @"id";
NSString *const kChatEventId = @"event_id";
NSString *const kFromUserId = @"from_user_id";
NSString *const kToUserId = @"to_user_id";
NSString *const kChatFirstName = @"first_name";
NSString *const kChatLastName = @"last_name";
NSString *const kChatImage = @"image";
NSString *const kUnreadMsgCount = @"Count";

@implementation PrivateChatListModel
- (instancetype)initWithChatListDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.userId = [self objectOrNilForKey:kUserId fromDictionary:dict];
        self.eventId = [self objectOrNilForKey:kChatEventId fromDictionary:dict];
        self.fromUserId = [self objectOrNilForKey:kFromUserId fromDictionary:dict];
        self.toUserId = [self objectOrNilForKey:kToUserId fromDictionary:dict];
        self.fisrtName =  [self objectOrNilForKey:kChatFirstName fromDictionary:dict];
        self.lastName = [self objectOrNilForKey:kChatLastName fromDictionary:dict];
        self.image = [self objectOrNilForKey:kChatImage fromDictionary:dict];
        if ([dict objectForKey:kBadgeCount]) {
             self.unreadMsgCount = [self objectOrNilForKey:kUnreadMsgCount fromDictionary:[dict objectForKey:kBadgeCount]];
        }
       
    }
    return self;
}

+ (void)getChatListData:(NSDictionary *)params withSuccessBlock:(ChatListBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kChatListService postData:parameters callBackBlock:^(id response, NSError *error) {
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    block(YES, [webResponse.result lastObject], error);
                    
                }
                else {
                    block(NO, nil, error);
                }
            }
            else {
                block(NO, nil, error);
            }
        }
        else {
            block(NO, nil, error);
        }
    }];
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}
@end
