//
//  UserTable.h
//  JUFL
//
//  Created by Ankur Arya on 08/07/15.
//  Copyright (c) 2015 Ankur Arya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserTable : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * mobileNumber;
@property (nonatomic, retain) NSString * countryCode;
@property (nonatomic, retain) NSNumber * userID;

@end
