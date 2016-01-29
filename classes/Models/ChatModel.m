//
//  ChatModel.m
//  jufl
//
//  Created by Dhirendra Kumar on 1/27/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import "ChatModel.h"
/*
 /////private
 "chatInfo":
 {
 "message": 110,
 "event_id": "317",
 "sender_id": 109,
 "receipt_id": 110,
 "chat_msg_id": 24,
 "chat_time": 110,
 "groupbadgeCount": 5,
 "privatebadgeCount": 5
 },
 "userInfo":
 {
 "id": null,
 "first_name": "Dhirendra",
 "last_name": "Kumar",
 "image": "http://54.66.156.48/jufl_files/profile/http://54.66.156.48/jufl_files/profile/56a8a865105f60.93702834.jpg"
 }
 }
//Group
 {
 "Success": 1,
 "Message": "",
 "Result": [
 {
 "chatInfo": {
 "message": "Hellos ",
 "event_id": "322",
 "sender_id": 109,
 "chat_msg_id": 24,
 "chat_time": "1453969282",
 "groupBadgeCount": 0,
 "privateBadgeCount": 0
 },
 "userInfo": {
 "id": "109",
 "first_name": "Dhirendra",
 "last_name": "Kumar",
 "image": "http://54.66.156.48/jufl_files/profile/56a8a865105f60.93702834.jpg"
 }
 }
 
 */


NSString *const kUserId = @"id";
NSString *const kChatFirstName = @"first_name";
NSString *const kChatLastName = @"last_name";
NSString *const kChatImage = @"image";
NSString *const kChatDateTime = @"chat_time";
NSString *const kChatEventId = @"event_id";
NSString *const kChatMessageId = @"chat_msg_id";

@implementation ChatModel
- (instancetype)initWithChatDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        if ([dict objectForKey:kUserInfo]) {
            self.userId = [self objectOrNilForKey:kUserId fromDictionary:[dict objectForKey:kUserInfo]];
            self.fisrtName = [self objectOrNilForKey:kChatFirstName fromDictionary:[dict objectForKey:kUserInfo]];
            self.lastName =  [self objectOrNilForKey:kChatLastName fromDictionary:[dict objectForKey:kUserInfo]];
            self.image = [self objectOrNilForKey:kChatImage fromDictionary:[dict objectForKey:kUserInfo]];

        }
        if ([dict objectForKey:kChatInfo]) {
            self.eventId = [self objectOrNilForKey:kChatEventId fromDictionary:[dict objectForKey:kChatInfo]];
            self.chatDateTime = [NSDate dateWithTimeIntervalSince1970:[[self objectOrNilForKey:kChatDateTime fromDictionary:[dict objectForKey:kChatInfo]] doubleValue]];
            self.message =  [self objectOrNilForKey:kChatMessage fromDictionary:[dict objectForKey:kChatInfo]];
            self.messageId = [self objectOrNilForKey:kChatMessageId fromDictionary:[dict objectForKey:kChatInfo]];
        }
    }
    return self;
}

//for get chat
+ (void)getGroupChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kGetChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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

//for get latest chat or refresh
+ (void)getLatestChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kGetLatestChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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

//for post caht
+ (NSDictionary *)getDictionaryFromModel:(ChatModel *)chat addLocation:(BOOL)location {
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc]init];
    
    if (chat.chatDateTime) {
        [eventDict setObject: [NSString stringWithFormat:@"%.0f", [chat.chatDateTime timeIntervalSince1970]] forKey:kChatDateTime];
    }
    
    return eventDict;
}

+ (void)postGroupChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kPostGroupChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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

+ (void)postPrivateChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kPostPrivateChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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
