//
//  Contacts.m
//
//  Created by Ankur  on 15/07/15
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "Contacts.h"
#import "RMPhoneFormat.h"


NSString *const kContactsFirstNamePhonetic = @"firstNamePhonetic";
NSString *const kContactsFirstName = @"firstName";
NSString *const kContactsId = @"id";
NSString *const kContactsCompany = @"company";
NSString *const kContactsBirthday = @"birthday";
NSString *const kContactsJobTitle = @"jobTitle";
NSString *const kContactsUpdatedAt = @"updatedAt";
NSString *const kContactsCreatedAt = @"createdAt";
NSString *const kContactsDepartment = @"department";
NSString *const kContactsLastName = @"lastName";
NSString *const kContactsImage = @"image";
NSString *const kContactsImageData = @"imageData";
NSString *const kContactsPhone = @"phones";

@interface Contacts ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Contacts

@synthesize firstNamePhonetic = _firstNamePhonetic;
@synthesize firstName = _firstName;
@synthesize contactId = _contactId;
@synthesize company = _company;
@synthesize birthday = _birthday;
@synthesize jobTitle = _jobTitle;
@synthesize updatedAt = _updatedAt;
@synthesize createdAt = _createdAt;
@synthesize department = _department;
@synthesize lastName = _lastName;
@synthesize image = _image;
@synthesize mobileNo = _mobileNo;

+ (Contacts *)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        if(!sharedInstance)
        {
            sharedInstance = [[self alloc] init];
        }
        ((Contacts *)sharedInstance).contactsArray = [NSMutableArray array];
        ((Contacts *)sharedInstance).friendsArray = [NSMutableArray array];
        ((Contacts *)sharedInstance).addressBookArray = [NSArray array];
        ((Contacts *)sharedInstance).contactManager = [KTSContactsManager sharedManager];
        ((Contacts *)sharedInstance).isFetchingContacts = NO;
        [Utils createBackGroundQueue:^{
           [((Contacts *)sharedInstance)fetchContactsFromAddressBookWithHandler:^(BOOL success, NSArray *appUser, NSArray *nonAppUser, NSError *error) {
               [Utils stopActivityIndicatorInView];
               ((Contacts *)sharedInstance).contactsArray = [nonAppUser mutableCopy];
               ((Contacts *)sharedInstance).friendsArray = [appUser mutableCopy];
           }];
        }];
    });
    return sharedInstance;
}

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
            self.firstNamePhonetic = [self objectOrNilForKey:kContactsFirstNamePhonetic fromDictionary:dict];
            self.firstName = [self objectOrNilForKey:kContactsFirstName fromDictionary:dict];
            self.contactId = [self objectOrNilForKey:kContactsId fromDictionary:dict];
            self.company = [self objectOrNilForKey:kContactsCompany fromDictionary:dict];
            self.birthday = [self objectOrNilForKey:kContactsBirthday fromDictionary:dict];
            self.jobTitle = [self objectOrNilForKey:kContactsJobTitle fromDictionary:dict];
            self.updatedAt = [self objectOrNilForKey:kContactsUpdatedAt fromDictionary:dict];
            self.createdAt = [self objectOrNilForKey:kContactsCreatedAt fromDictionary:dict];
            self.department = [self objectOrNilForKey:kContactsDepartment fromDictionary:dict];
            self.lastName = [self objectOrNilForKey:kContactsLastName fromDictionary:dict];
            self.image = [self objectOrNilForKey:kContactsImageData fromDictionary:dict];
            self.imageUrl = [self objectOrNilForKey:kContactsImage fromDictionary:dict];
            self.fullName = [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
        NSArray *phoneArray = [self objectOrNilForKey:kContactsPhone fromDictionary:dict];
        if (phoneArray.count > 0) {
            for (NSDictionary *phoneDict in  phoneArray) {
                if ([phoneDict objectNonNullForKey:@"value"]) {
                    self.mobileNo = [self getFormattedMobileNumber:[phoneDict objectNonNullForKey:@"value"]];
                    if ([self.mobileNo isEqualToString:@""]) {
                        
                    }
                    break;
                }
            }
        }
    }
    
    return self;
    
}

- (NSString *)getFormattedMobileNumber:(NSString *)originalNumber {
    RMPhoneFormat *fmt = [[RMPhoneFormat alloc] init];
    NSString *formattedNumber = @"";
    NSCharacterSet *toExclude = [NSCharacterSet characterSetWithCharactersInString:@"/ ()- "];

    NSString *numberString = originalNumber;
    formattedNumber = [fmt format:numberString];
    formattedNumber = [[formattedNumber componentsSeparatedByCharactersInSet:toExclude] componentsJoinedByString: @""];
    
    formattedNumber = [formattedNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
    return formattedNumber;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.firstNamePhonetic forKey:kContactsFirstNamePhonetic];
    [mutableDict setValue:self.firstName forKey:kContactsFirstName];
    [mutableDict setValue:self.contactId forKey:kContactsId];
    [mutableDict setValue:self.company forKey:kContactsCompany];
    [mutableDict setValue:self.birthday forKey:kContactsBirthday];
    [mutableDict setValue:self.jobTitle forKey:kContactsJobTitle];
    [mutableDict setValue:self.updatedAt forKey:kContactsUpdatedAt];
    [mutableDict setValue:self.createdAt forKey:kContactsCreatedAt];
    [mutableDict setValue:self.department forKey:kContactsDepartment];
    [mutableDict setValue:self.lastName forKey:kContactsLastName];
    [mutableDict setValue:self.image forKey:kContactsImageData];
    [mutableDict setValue:self.imageUrl forKey:kContactsImage];

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

    self.firstNamePhonetic = [aDecoder decodeObjectForKey:kContactsFirstNamePhonetic];
    self.firstName = [aDecoder decodeObjectForKey:kContactsFirstName];
    self.contactId = [aDecoder decodeObjectForKey:kContactsId];
    self.company = [aDecoder decodeObjectForKey:kContactsCompany];
    self.birthday = [aDecoder decodeObjectForKey:kContactsBirthday];
    self.jobTitle = [aDecoder decodeObjectForKey:kContactsJobTitle];
    self.updatedAt = [aDecoder decodeObjectForKey:kContactsUpdatedAt];
    self.createdAt = [aDecoder decodeObjectForKey:kContactsCreatedAt];
    self.department = [aDecoder decodeObjectForKey:kContactsDepartment];
    self.lastName = [aDecoder decodeObjectForKey:kContactsLastName];
    self.image = [aDecoder decodeObjectForKey:kContactsImageData];
    self.imageUrl = [aDecoder decodeObjectForKey:kContactsImage];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_firstNamePhonetic forKey:kContactsFirstNamePhonetic];
    [aCoder encodeObject:_firstName forKey:kContactsFirstName];
    [aCoder encodeObject:_contactId forKey:kContactsId];
    [aCoder encodeObject:_company forKey:kContactsCompany];
    [aCoder encodeObject:_birthday forKey:kContactsBirthday];
    [aCoder encodeObject:_jobTitle forKey:kContactsJobTitle];
    [aCoder encodeObject:_updatedAt forKey:kContactsUpdatedAt];
    [aCoder encodeObject:_createdAt forKey:kContactsCreatedAt];
    [aCoder encodeObject:_department forKey:kContactsDepartment];
    [aCoder encodeObject:_lastName forKey:kContactsLastName];
    [aCoder encodeObject:_image forKey:kContactsImageData];
    [aCoder encodeObject:_imageUrl forKey:kContactsImage];
}

- (id)copyWithZone:(NSZone *)zone
{
    Contacts *copy = [[Contacts alloc] init];
    
    if (copy) {

        copy.firstNamePhonetic = [self.firstNamePhonetic copyWithZone:zone];
        copy.firstName = [self.firstName copyWithZone:zone];
        copy.contactId = self.contactId;
        copy.company = [self.company copyWithZone:zone];
        copy.birthday = [self.birthday copyWithZone:zone];
        copy.jobTitle = [self.jobTitle copyWithZone:zone];
        copy.updatedAt = [self.updatedAt copyWithZone:zone];
        copy.createdAt = [self.createdAt copyWithZone:zone];
        copy.department = [self.department copyWithZone:zone];
        copy.lastName = [self.lastName copyWithZone:zone];
        copy.image = self.image;
    }
    
    return copy;
}

- (void)fetchContactsFromAddressBookWithHandler:(ContactsBlock)block {
    self.isFetchingContacts = YES;
    UserModel *currentUser = [[UserModel alloc]initWithUserTable:[UserModel currentUser]];
    [Utils createBackGroundQueue:^{
        [self.contactManager importContacts:^(NSArray *contacts) {
            if (contacts) {
                NSMutableArray *array = [[NSMutableArray alloc]init];
                for (NSDictionary *dict in contacts) {
                    Contacts *contact = [[Contacts alloc]initWithDictionary:dict];
                    if (![contact.mobileNo containsString:currentUser.mobileNo] && [NRValidation isValidString:contact.firstName]) {
                        [array addObject:contact];
                    }
                }
                self.addressBookArray = [NSArray arrayWithArray:array];
                if (self.addressBookArray.count>0) {
                    [self requestForAppUsersWithContactArrayWithHandler:block];
                }
                else {
                    block(NO, nil, nil, nil);
                }
            }
            else {
                block(NO, nil, nil, nil);
            }
            
        }];
    }];
   
}

- (NSArray *)contactNumberFromArray:(NSArray *)contacts
{
    NSMutableArray *contactArray = [NSMutableArray array];
    for(Contacts *contact in contacts)
    {
        if (contact.mobileNo) {
           [contactArray addObject:contact.mobileNo];
        }
    }
    
    NSSet *uniqueNumbers = [NSSet setWithArray:contactArray];
    NSArray *uniqueNumberArray = [uniqueNumbers allObjects];
    return uniqueNumberArray;
}

- (void)requestForAppUsersWithContactArrayWithHandler:(ContactsBlock)block
{
    NSDictionary *params = @{kContactsArray:[self contactNumberFromArray:self.addressBookArray]};

    [Connection callServiceWithName:kParseContactsService postData:params callBackBlock:^(id response, NSError *error) {
        [Utils createMainQueue:^{
            if(success(response, error))
            {
                NSMutableArray *friends = [NSMutableArray array];
                NSMutableArray *inviteUser = [NSMutableArray array];
                
                for(NSDictionary *dictAppUser in [[[response objectForKey:@"Result"] firstObject] objectForKey:@"appuser"])
                {
                    UserModel *user = [[UserModel alloc]initWithDictionary:dictAppUser];
                    if ([NRValidation isValidString:user.firstName]) {
                        [friends addObject:user];
                    }
                }
                
                for(NSString *number in [[[response objectForKey:@"Result"] firstObject] objectForKey:@"invite"])
                {
                    NSDictionary *inviteDict = @{kContactsPhone:@[@{@"value":number}]};
                    Contacts *user = [[Contacts alloc]initWithDictionary:inviteDict];
                    
                    [inviteUser addObject:user];
                }
                
                self.friendsArray = [[self getSortedArray:[NSArray arrayWithArray:friends]]mutableCopy];
                self.contactsArray = [[self getSortedArray:[self getNonAppUsers:inviteUser]]mutableCopy];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"FriendsUpdateNotification"
                 object:self];
                [Contacts sharedInstance].isFetchingContacts = NO;
                block(YES, self.friendsArray, self.contactsArray,nil);
            }

        }];
    }];
}

- (NSArray *)getSortedArray:(NSArray *)originalArray {
    NSSortDescriptor *alphaNumSD = [NSSortDescriptor sortDescriptorWithKey:@"firstName"
                                                                 ascending:YES
                                                                comparator:^(NSString *string1, NSString *string2)
                                    {
                                        return [string1 compare:string2 options:NSNumericSearch|NSCaseInsensitiveSearch];
                                    }];
    
    return [originalArray sortedArrayUsingDescriptors:@[alphaNumSD]];
}

+ (Contacts *)getContactForNumber:(NSString*)phoneNumber
{
    Contacts *contact = nil ;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mobileNo Contains %@",phoneNumber];
    NSArray *arr = [[Contacts sharedInstance].addressBookArray filteredArrayUsingPredicate:predicate];
    contact  = [arr firstObject];
    
    return  contact;
}

- (NSArray *)getNonAppUsers :(NSArray *)contactArray {
    NSMutableArray *nonAppUserArray = [[NSMutableArray alloc]init];
    for (Contacts *contact in  contactArray) {
        Contacts *nonAppUser =  [Contacts getContactForNumber:contact.mobileNo];
        [nonAppUserArray addObject:nonAppUser];
    }
    
    return [NSArray arrayWithArray:nonAppUserArray];
}


-(BOOL)isUserExistInContacts:(UserModel *)user {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mobileNo Contains %@",user.mobileNo];
    NSArray *arr = [self.addressBookArray filteredArrayUsingPredicate:predicate];
    NSArray *arr2 = [self.friendsArray filteredArrayUsingPredicate:predicate];
    
    UserModel *currentUser = [[UserModel alloc]initWithUserTable:[UserModel currentUser]];
    if (arr2.count != 0 || arr.count != 0 || [user.mobileNo isEqualToString:currentUser.mobileNo]) {
        return YES;
    };
    return NO;
}

+ (void)askContactPermission:(ContactsSuccessBlock)completion {
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                completion(YES);
                
            } else {
                // User denied access
                completion(NO);
                // Display an alert telling user the contact could not be added
            }
            
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        completion(YES);
        
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        completion(NO);
    }
}

@end
