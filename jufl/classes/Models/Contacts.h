//
//  Contacts.h
//
//  Created by Ankur  on 15/07/15
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTSContactsManager.h"

typedef void (^ContactsBlock)(BOOL success, NSArray *appUser, NSArray *nonAppUser, NSError *error);
typedef void (^ContactsSuccessBlock)(BOOL success);
@interface Contacts : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *firstNamePhonetic;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, assign) NSNumber *contactId;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *jobTitle;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *department;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *mobileNo;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) KTSContactsManager *contactManager;
@property (strong, nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSArray *addressBookArray;
@property (nonatomic, assign) BOOL isContactsAllowed;
@property (nonatomic, assign) BOOL isFetchingContacts;

+ (Contacts *)sharedInstance;
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

- (void)fetchContactsFromAddressBookWithHandler:(ContactsBlock)block;
- (BOOL)isUserExistInContacts:(UserModel *)user;
+ (void)askContactPermission:(ContactsSuccessBlock)completion;
@end
