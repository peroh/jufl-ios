//
//  UserModel.m
//
//  Created by Ankur Arya on 08/07/15
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "UserModel.h"


NSString *const kUserModelCountry = @"country";
NSString *const kUserModelId = @"id";
NSString *const kUserModelMobileNo = @"mobile_no";
NSString *const kUserModelLastName = @"last_name";
NSString *const kUserModelImage = @"image";
NSString *const kUserModelCountryCode = @"country_code";
NSString *const kUserModelFirstName = @"first_name";
NSString *const kUserModelBlock= @"block";
NSString *const kUserModelFlag= @"flag";
NSString *const kUserModelDecide= @"decide";

@interface UserModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation UserModel

@synthesize country = _country;
@synthesize userId = _userId;
@synthesize mobileNo = _mobileNo;
@synthesize lastName = _lastName;
@synthesize image = _image;
@synthesize countryCode = _countryCode;
@synthesize firstName = _firstName;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.country = [self objectOrNilForKey:kUserModelCountry fromDictionary:dict];
        self.userId = numberValue([self objectOrNilForKey:kUserModelId fromDictionary:dict]);
        self.mobileNo = [self objectOrNilForKey:kUserModelMobileNo fromDictionary:dict];
        self.lastName = [self objectOrNilForKey:kUserModelLastName fromDictionary:dict];
        self.image = [self objectOrNilForKey:kUserModelImage fromDictionary:dict];
        self.countryCode = [self objectOrNilForKey:kUserModelCountryCode fromDictionary:dict];
        self.firstName = [self objectOrNilForKey:kUserModelFirstName fromDictionary:dict];
        self.isSelected = NO;
        self.isBlocked = [[self objectOrNilForKey:kUserModelBlock fromDictionary:dict] boolValue];
        self.isImageFlagged = [[self objectOrNilForKey:kUserModelFlag fromDictionary:dict] boolValue];
        self.userResponse = [[self objectOrNilForKey:kUserModelDecide fromDictionary:dict]integerValue];
        self.fullName = [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.country forKey:kUserModelCountry];
    [mutableDict setValue:self.userId forKey:kUserModelId];
    [mutableDict setValue:self.mobileNo forKey:kUserModelMobileNo];
    [mutableDict setValue:self.lastName forKey:kUserModelLastName];
    [mutableDict setValue:self.image forKey:kUserModelImage];
    [mutableDict setValue:self.countryCode forKey:kUserModelCountryCode];
    [mutableDict setValue:self.firstName forKey:kUserModelFirstName];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.country = [aDecoder decodeObjectForKey:kUserModelCountry];
    self.userId = [aDecoder decodeObjectForKey:kUserModelId];
    self.mobileNo = [aDecoder decodeObjectForKey:kUserModelMobileNo];
    self.lastName = [aDecoder decodeObjectForKey:kUserModelLastName];
    self.image = [aDecoder decodeObjectForKey:kUserModelImage];
    self.countryCode = [aDecoder decodeObjectForKey:kUserModelCountryCode];
    self.firstName = [aDecoder decodeObjectForKey:kUserModelFirstName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_country forKey:kUserModelCountry];
    [aCoder encodeObject:_userId forKey:kUserModelId];
    [aCoder encodeObject:_mobileNo forKey:kUserModelMobileNo];
    [aCoder encodeObject:_lastName forKey:kUserModelLastName];
    [aCoder encodeObject:_image forKey:kUserModelImage];
    [aCoder encodeObject:_countryCode forKey:kUserModelCountryCode];
    [aCoder encodeObject:_firstName forKey:kUserModelFirstName];
}

- (id)copyWithZone:(NSZone *)zone
{
    UserModel *copy = [[UserModel alloc] init];
    
    if (copy) {
        
        copy.country = [self.country copyWithZone:zone];
        copy.userId = self.userId;
        copy.mobileNo = [self.mobileNo copyWithZone:zone];
        copy.lastName = [self.lastName copyWithZone:zone];
        copy.image = [self.image copyWithZone:zone];
        copy.countryCode = [self.countryCode copyWithZone:zone];
        copy.firstName = [self.firstName copyWithZone:zone];
    }
    
    return copy;
}

+ (NSNumber *)userId
{
    UserTable *userTable = [CoreDataHandler getUserEntity];
    if(userTable.userID||[userTable.userID.stringValue length]>0)
    {
        return userTable.userID;
    }
    return nil;
}

+ (UserTable *)currentUser
{
    return [CoreDataHandler getUserEntity];
}

- (instancetype)initWithUserTable:(UserTable *)userTable{
    self = [super init];
    
    if (self) {
        
        self.firstName = userTable.firstName;
        self.lastName = userTable.lastName;
        self.fullName = [NSString stringWithFormat:@"%@ %@",userTable.firstName, userTable.lastName];
        self.userId = userTable.userID;
        self.mobileNo = userTable.mobileNumber;
        self.countryCode = userTable.countryCode;
        self.image = userTable.image;
    }
    return self;
}

#pragma mark - API Calls

+ (void)verifyMobileNumber:(NSString *)mobileNumber withCountryCode:(NSString *)code completion:(CurrentUserModelBlock)block {
    NSMutableDictionary *params = [@{kMobileNumber:mobileNumber, kCountryCode :code}mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [params setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    
    [Connection callServiceWithName:kSendOTPService postData:params callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    NSDictionary *userDict = nil;
                    if([[webResponse.result lastObject][@"User Profile"] isKindOfClass:[NSArray class]]) {
                        userDict = [[webResponse.result lastObject][@"User Profile"]lastObject];
                    }
                    else {
                        userDict = [webResponse.result lastObject][@"User Profile"];
                    }
                    if ([[userDict objectStringNonNullForKey:@"deleted"]boolValue]) {
                        [[Utils sharedInstance]openAlertViewWithTitle:kTitle message:@"Admin Has Deactivated The Account" buttons:@[@"Ok"] completion:^(UIAlertView *alert, NSInteger buttonIndex) {
                            
                        }];
                         block(NO, nil,nil, error);
                    }
                    else {
                    NSString *otp = [webResponse.result lastObject][@"OTP"];
                    UserModel *currentUser = [[UserModel alloc]initWithDictionary:userDict];
                    block(YES, currentUser,otp, error);
                    }
                }
                else {
                    block(NO, nil,nil, error);
                }
            }
            else {
                block (NO, nil,nil, error);
            }
        }
        else {
            block (NO, nil,nil, error);
        }
    }];
}

+ (void)updateUserProfileWithParameters:(NSDictionary *)params completion:(CurrentUserModelBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kProfileService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    NSDictionary *userDict = [webResponse.result lastObject];
                    
                    
                    UserModel *currentUser = [[UserModel alloc]initWithDictionary:userDict];
                    //                    [CoreDataHandler saveUserDataWithModel:currentUser];
                    block(YES, currentUser, nil, error);
                }
                else {
                    block(NO, nil, nil, error);
                }
            }
            else {
                block (NO, nil, nil, error);
            }
        }
        else {
            block (NO, nil, nil, error);
        }
    }];
}

+ (void)updateUserProfileWithParameters:(NSDictionary *)params andImage:(UIImage *)image completion:(CurrentUserModelBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithImages:@[image] params:parameters serviceIdentifier:kProfileService callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                if(webResponse.result.count>0) {
                    NSDictionary *userDict = [webResponse.result lastObject];
                    
                    
                    UserModel *currentUser = [[UserModel alloc]initWithDictionary:userDict];
                    //                      [CoreDataHandler saveUserDataWithModel:currentUser];
                    block(YES, currentUser, nil, error);
                }
                else {
                    block(NO, nil, nil, error);
                }
            }
            else {
                block (NO, nil, nil, error);
            }
        }
        else {
            block (NO, nil, nil, error);
        }
        
    }];
}

+ (void)blockUserWithParameters:(NSDictionary *)params completion:(SuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kFriendBlockService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                NSDictionary *userDict = [webResponse.result lastObject];
                block(YES, userDict, error);
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

+ (void)flagUserWithParameters:(NSDictionary *)params completion:(SuccessBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kFlagImageService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                NSDictionary *userDict = [webResponse.result lastObject];
                block(YES, userDict, error);
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


+ (void)getParticipantListWithParameters:(NSDictionary *)params completion:(FriendUserModelBlock)block {
    NSMutableDictionary *parameters = [params mutableCopy];
    
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    
    [Connection callServiceWithName:kParticipantListService postData:params callBackBlock:^(id response, NSError *error) {
        
        if(success(response, error))
        {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc]initWithData:response];
            NSMutableArray *invitedUsers = [NSMutableArray array];

            for(NSDictionary *userDict in webResponse.result)
            {
                UserModel *user = [[UserModel alloc]initWithDictionary:userDict];
                user.userExistInContacts = [[Contacts sharedInstance]isUserExistInContacts:user];
                [invitedUsers addObject:user];
            }
            block(YES, [self getSortedArray:invitedUsers], error);
        }
        else {
            block(NO, nil, error);
        }
        
    }];

}

+ (NSArray *)getSortedArray:(NSArray *)originalArray {
    NSSortDescriptor *alphaNumSD = [NSSortDescriptor sortDescriptorWithKey:@"firstName"
                                                                 ascending:YES
                                                                comparator:^(NSString *string1, NSString *string2)
                                    {
                                        return [string1 compare:string2 options:NSNumericSearch|NSCaseInsensitiveSearch];
                                    }];
    
    return [originalArray sortedArrayUsingDescriptors:@[alphaNumSD]];
}

+ (void)logoutUserWithParameters:(NSDictionary *)params completion:(SuccessBlock)block {
     NSMutableDictionary *parameters = [params mutableCopy];
    if ([NRValidation isValidString:[[SharedClass sharedInstance] deviceToken]]) {
        [parameters setObject:[[SharedClass sharedInstance] deviceToken] forKey:kDeviceToken];
    }
    [Utils startActivityIndicatorWithMessage:kPleaseWait];
    [Connection callServiceWithName:kSignOutService postData:parameters callBackBlock:^(id response, NSError *error) {
        [Utils stopActivityIndicatorInView];
        if(success(response, error)) {
            WebServiceResponse *webResponse = [[WebServiceResponse alloc] initWithData:((NSDictionary *)response)];
            
            if(webResponse)
            {
                NSDictionary *userDict = [webResponse.result lastObject];
                block(YES, userDict, error);
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
@end
