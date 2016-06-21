//
//  UserModel.h
//
//  Created by Ankur Arya on 08/07/15
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserTable, UserModel;

typedef void (^CurrentUserModelBlock)(BOOL success, UserModel *currentUser, NSString *otp, NSError *error);
typedef void (^FriendUserModelBlock)(BOOL success, NSArray *users, NSError *error);

typedef void (^SuccessBlock)(BOOL success, NSDictionary *response, NSError *error);

@interface UserModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *mobileNo;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isBlocked;
@property (nonatomic, assign) BOOL isImageFlagged;
@property (nonatomic, assign) EventResponse userResponse;
@property (nonatomic, assign) BOOL userExistInContacts;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
- (instancetype)initWithUserTable:(UserTable *)userTable;

+ (NSNumber *)userId;
+ (UserTable *)currentUser;

+ (void)verifyMobileNumber:(NSString *)mobileNumber withCountryCode:(NSString *)code completion:(CurrentUserModelBlock)block;

+ (void)updateUserProfileWithParameters:(NSDictionary *)params completion:(CurrentUserModelBlock)block;
+ (void)updateUserProfileWithParameters:(NSDictionary *)params andImage:(UIImage *)image completion:(CurrentUserModelBlock)block;

+ (void)blockUserWithParameters:(NSDictionary *)params completion:(SuccessBlock)block;
+ (void)flagUserWithParameters:(NSDictionary *)params completion:(SuccessBlock)block;

+ (void)logoutUserWithParameters:(NSDictionary *)params completion:(SuccessBlock)block;

+ (void)getParticipantListWithParameters:(NSDictionary *)params completion:(FriendUserModelBlock)block;


@end
