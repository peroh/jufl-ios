//
//  CoreDataHandler.m
//  AroundAbout
//
//  Created by Naveen Rana on 21/01/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import "CoreDataHandler.h"
#import "UserModel.h"

@interface CoreDataHandler ()


@end

@implementation CoreDataHandler

#pragma mark - Clear Database

#pragma mark - User Details

+ (UserTable *)getUserEntityForUserID:(NSString *)userID
{
    UserTable *friendModel = (UserTable *)[Fetchsavefromcoredata fetchupdatemanagedobjectfromdatabaseforentity:@"UserTable" attributename:@"userID" predicate:userID];
    return friendModel;
}

+ (UserTable *)getUserEntity
{
    return [[self class] getUserEntityForUserID:((NSNumber *)[UserDefaluts objectForKey:kCurrentUserID]).stringValue];
    //return (UserTable *)[Fetchsavefromcoredata insertUpdatefromDatabaseforentity:@"UserTable"];
}


+ (void)saveUserDataWithModel:(UserModel *)userModel{
    
    UserTable *userTable;
    if([UserDefaluts objectForKey:kCurrentUserID])
        userTable = [[self class] getUserEntityForUserID:((NSNumber *)[UserDefaluts objectForKey:kCurrentUserID]).stringValue];
    else
        userTable = (UserTable *)[Fetchsavefromcoredata insertUpdatefromDatabaseforentity:@"UserTable"];
    
    if (userModel) {
        if (userModel.firstName)
            userTable.firstName = userModel.firstName;
        if (userModel.lastName)
            userTable.lastName = userModel.lastName;
        if (userModel.userId)
            userTable.userID = userModel.userId;
        if (userModel.mobileNo)
            userTable.mobileNumber = userModel.mobileNo;
        if (userModel.countryCode)
            userTable.countryCode = userModel.countryCode;
        if (userModel.image)
            userTable.image = userModel.image;
        
        if (userModel.userId) {
            if([UserDefaluts objectForKey:kCurrentUserID])
                [UserDefaluts removeObjectForKey:kCurrentUserID];
            [UserDefaluts setObject:userModel.userId forKey:kCurrentUserID];
        }
        
    }
    
    [[CoreDataConfiguration sharedInstance] saveContext];
    
}

@end
