//
//  ChatModel.m
//  jufl
//
//  Created by Dhirendra Kumar on 1/27/16.
//  Copyright © 2016 Ankur Arya. All rights reserved.
//

#import "ChatModel.h"
NSString *const kGroupUserId = @"id";
NSString *const kChatGroupFirstName = @"first_name";
NSString *const kChatGroupLastName = @"last_name";
NSString *const kChatGroupImage = @"image";
NSString *const kChatDateTime = @"chat_time";
NSString *const kChatGroupEventId = @"event_id";
NSString *const kChatMessageId = @"chat_msg_id";

@implementation ChatModel
- (instancetype)initWithChatDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        if ([dict objectForKey:kUserInfo]) {
            self.userId = [self objectOrNilForKey:kGroupUserId fromDictionary:[dict objectForKey:kUserInfo]];
            self.fisrtName = [self objectOrNilForKey:kChatGroupFirstName fromDictionary:[dict objectForKey:kUserInfo]];
            self.lastName =  [self objectOrNilForKey:kChatGroupLastName fromDictionary:[dict objectForKey:kUserInfo]];
            self.image = [self objectOrNilForKey:kChatGroupImage fromDictionary:[dict objectForKey:kUserInfo]];

        }
            self.eventId = [self objectOrNilForKey:kChatGroupEventId fromDictionary:dict];
            self.chatDateTime = [NSDate dateWithTimeIntervalSince1970:[[self objectOrNilForKey:kChatDateTime fromDictionary:dict] doubleValue]];
            self.message =  [self objectOrNilForKey:kChatMessage fromDictionary:dict];
           self.messageId = [NSNumber numberWithInt:[[self objectOrNilForKey:kChatMessageId fromDictionary:dict] intValue]];//[NSString stringWithFormat:@"%@",[self objectOrNilForKey:kChatMessageId fromDictionary:dict]];
    }
    return self;
}

//for get group chat
+ (void)getGroupChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kGetGroupChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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

//for get private chat
+ (void)getPrivateChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kGetPrivateChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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
+ (void)getLatestGroupChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kGetLatestGroupChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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

+ (void)getLatestPrivateChatData:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kGetLatestPrivateChatService postData:parameters callBackBlock:^(id response, NSError *error) {
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

//for mute and unmute event notification
+ (void)setEventMuteUnmuteNotification:(NSDictionary *)params withSuccessBlock:(ChatBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Connection callServiceWithName:kGetEventNotification postData:parameters callBackBlock:^(id response, NSError *error) {
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
