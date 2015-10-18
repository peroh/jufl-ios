//
//  CoreDataHandler.h
//  AroundAbout
//
//  Created by Naveen Rana on 21/01/15.
//  Copyright (c) 2015 Naveen Rana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fetchsavefromcoredata.h"
#import "ModelHeader.h"
#import "UserTable.h"


@class UserModel;
@interface CoreDataHandler : NSObject

+ (UserTable *)getUserEntity;
+ (void)saveUserDataWithModel:(UserModel *)userModel;

@end
