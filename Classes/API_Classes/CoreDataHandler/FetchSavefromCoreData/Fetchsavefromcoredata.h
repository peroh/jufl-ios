//
//  Fetchsavefromcoredata.h
//  HvmsScan
//
//  Created by naveen rana on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fetchsavefromcoredata : NSObject
{
     

}
@property(strong,nonatomic) NSManagedObjectContext *managedobjectcontext;

+ (void)deleteAllDataForEntity:(NSString *)entityName;
+ (void)deleteAllmanagedobjectfromdatabaseExceptforintentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate;

+(NSArray *)fetchRecordsFromArrayforEntity:(NSString *)entityname resultArray:(NSArray *)resultArray attribute:(NSString *)attribute;

+(NSArray *)arrayfromentityresult:(NSString *)entityname;


//general fetch method
+(NSArray *)fetchfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate  distinctrecordkey:(NSString *)keyvalue;

//general fetch without key
+(NSArray *)fetchfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate ;

//general fetch for integer value
+(NSArray *)fetchfromdatabaseforintentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate ;

+(NSManagedObject *)insertNewObjectforDatabaseforentity:(NSString *)entityname;

// general sorting fetch

+(NSArray *)fetchsortdataforentity:(NSString *)entityname  key:(NSString *)key ;


// general fetch with sort key and predicate

+(NSArray *)fetchsortdatawithpredicateforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate   key:(NSString *)key;


// General Fetch Managed Objects from database with unique result

+(NSArray *)fetchmanagedfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate  distinctrecordkey:(NSString *)keyvalue;

// update  inventory in database
+(NSManagedObject *)fetchmanagedobjectfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate;

 

//Insert/update  entity in database
+(NSManagedObject *)insertUpdatefromDatabaseforentity:(NSString *)entityname ;

//Fetch All Data from the Entity

+(NSArray *)fetchDictionaryFromDatabaseforEntity:(NSString *)entityname;

//update  Record in database
+(NSManagedObject *)fetchupdatemanagedobjectfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate ;

//update Record for int in database
+(NSManagedObject *)fetchupdatemanagedobjectfromdatabaseforintentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate ;

//fetchuniqurkeyfromdatabase fetch method
+(NSArray *)fetchuniquekeyfromdatabase:(NSString *)entityname distinctrecordkey:(NSString *)keyvalue;


//mark AND query
+(NSArray *)fetchwithtwoattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value;

+(NSManagedObject *)fetchManagedObjectwithtwoattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value;
+(NSManagedObject *)fetchManagedObjectwiththreeattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value  attribute3:(NSString *)attribute3 attribute3value:(NSString *)attribute3value;


+(NSArray *)fetchdistinctfromdatabaseforentity:(NSString *)entityname  resultArray:(NSArray *)resultArray attribute:(NSString *)attribute distinctrecordkey:(NSString *)keyvalue;

+(NSArray *)fetchAttributeRecordsFromArrayforEntity:(NSString *)entityname attribute:(NSString *)attribute attributeValue:(NSString *)attributeValue;

+(NSArray *)fetchRecordsNotInFromArrayforEntity:(NSString *)entityname resultArray:(NSArray *)resultArray attribute:(NSString *)attribute;

+(NSArray *)fetchRecordswiththreeattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value  attribute3:(NSString *)attribute3 attribute3value:(NSString *)attribute3value;


@end
