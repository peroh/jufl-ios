//
//  Fetchsavefromcoredata.m
//  HvmsScan
//
//  Created by naveen rana on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Fetchsavefromcoredata.h"


@implementation Fetchsavefromcoredata
@synthesize managedobjectcontext;

static NSManagedObjectContext *managedobjectcontext=nil;

+ (NSArray *)arrayfromentityresult:(NSString *)entityname
{
    //managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *resultentity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext
                                                                ];
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:resultentity];
//    [request setResultType:NSDictionaryResultType];
  	NSArray *fetchresult=[[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
    
    return fetchresult;

}

#pragma mark general fetch

+(NSArray *)fetchfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate  
{
	//managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==[c]\"%@\"",attributename,predicate]];
	[request setPredicate:predicates];	
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;
}



#pragma mark general fetch with sort key and predicate

+(NSArray *)fetchsortdatawithpredicateforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate   key:(NSString *)key
{
	//managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
	[request setPredicate:predicates];	
    
    NSSortDescriptor *sorDescriptor=[[NSSortDescriptor alloc] initWithKey:key ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sorDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;
}

/*
#pragma mark get Country name and Country id 
+(NSString *)getcountrynameandidfromdatabase:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate
{
	managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:managedobjectcontext];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=nil;
    
    if([attributename isEqualToString:@"countryid"])
    {
        predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
        [request setPredicate:predicates];	
        NSArray *resultarray=[managedobjectcontext executeFetchRequest:request error:nil];    
        NSString *countryname=nil;
        if([resultarray count]>0)
        {
            countryname=[[NSString alloc] init];
            Country *countryentity=nil;
            countryentity=[resultarray lastObject];
            countryname=countryentity.countryname;
            
        }
        return countryname;
        
    }
    
    if([attributename isEqualToString:@"countryname"])
    {
        predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
        [request setPredicate:predicates];	
        NSArray *resultarray=[managedobjectcontext executeFetchRequest:request error:nil];    
        NSString *countryid=nil;
        if([resultarray count]>0)
        {
            countryid=[[NSString alloc] init];
            Country *countryentity=nil;
            countryentity=[resultarray lastObject];
            countryid=countryentity.countryid;
            
        }
        return countryid;
        
    }
    
    
    return nil;
}
*/



#pragma mark general fetch for integer value
+(NSArray *)fetchfromdatabaseforintentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate 
{
    //managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%ld\"",attributename,(long)predicate]];
	[request setPredicate:predicates];	
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;

}


/*


#pragma mark Fetch all Other Delaler Information

+(NSMutableArray *)fetchallotherdelaers:(NSMutableDictionary *)args
{
    
    NSString *name=[args valueForKey:@"name"];
    NSString *city=[args valueForKey:@"city"];
    NSString *zipcode=[args valueForKey:@"zipcode"];
    NSString *country=[args valueForKey:@"country"];
    NSString *state=[args valueForKey:@"state"];
   // NSString *stateIDStr=[args valueForKey:@"stateId"];

    
    NSString *countryid=[Fetchsavefromcoredata getcountrynameandidfromdatabase:@"Country" attributename:@"countryname" predicate:country];
    NSString *stateid=[Fetchsavefromcoredata getStatenameandidfromdatabase:@"State" attributename:@"state" predicate:state];
     //   NSString *stateidStr = [Fetchsavefromcoredata getStatenameandidfromdatabase:@"State" attributename:@"stateId" predicate:stateIDStr];
    
    
    if([countryid length]<=0)
    {
        countryid=@"";
    }
    if([stateid length]<=0)
    {
        stateid=@"";
    }
    
    
    
    managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
    
	NSEntityDescription *dealerentity=[NSEntityDescription entityForName:@"Dealer" inManagedObjectContext:managedobjectcontext];
    
	NSFetchRequest *delaerrequest=[[NSFetchRequest alloc] init];
	[delaerrequest setEntity:dealerentity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"dealerName like[c] \"%@*\"",name]];
	[delaerrequest setPredicate:predicates];	
    
	NSArray *arrayofrecord=[managedobjectcontext executeFetchRequest:delaerrequest error:nil];
    
    NSArray *dealerwithidsarray=[arrayofrecord valueForKey:@"dealerId"];
    NSMutableSet *idfromnameset=[NSMutableSet setWithArray:dealerwithidsarray];
    
    //fetch delaer id from delaer table
    
    //predicates array
     
    NSEntityDescription *addressentity=[NSEntityDescription entityForName:@"Address" inManagedObjectContext:managedobjectcontext];
    
	NSFetchRequest *addressrequest=[[NSFetchRequest alloc] init];
	[addressrequest setEntity:addressentity];
    
  //  NSPredicate *addpredicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"city like[c] \"%@*\" AND zip like[c] \"%@*\" AND countryId ==\"%@\" OR stateId==\"%@\" AND entityTypeId==1",city,zipcode,countryid,stateid]];
    
    NSPredicate  *entitytypepredicate=[NSPredicate predicateWithFormat:@"entityTypeId==1"];
    
    
    NSPredicate *addpredicates=nil;
    if(([countryid length]<=0)&&([stateid length]<=0))
    {
        addpredicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"city like[c] \"%@*\" AND zip like[c] \"%@*\"",city,zipcode]];

    }
    else
    {
        if(([countryid length]>0)&&([stateid length]<=0))
        {
            addpredicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"city like[c] \"%@*\" AND zip like[c] \"%@*\" AND countryId ==\"%@\" ",city,zipcode,countryid]];
            
        }

        if(([countryid length]<=0)&&([stateid length]>0))
        {
            addpredicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"city like[c] \"%@*\" AND zip like[c] \"%@*\"  AND stateId==\"%@\"",city,zipcode,stateid]];
            
        } 
        
        if(([countryid length]>0)&&([stateid length]>0))
        {
              addpredicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"city like[c] \"%@*\" AND zip like[c] \"%@*\" AND countryId ==\"%@\" AND stateId==\"%@\"",city,zipcode,countryid,stateid]];
            
        } 
    }
   // addpredicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"city like[c] \"%@*\" AND zip like[c] \"%@*\" AND countryId ==\"%@\" AND stateId==\"%@\"",city,zipcode,countryid,stateid]];
    
    NSCompoundPredicate *finalpredicate=(NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:[NSMutableArray arrayWithObjects:entitytypepredicate,addpredicates, nil]];
    
	[addressrequest setPredicate:finalpredicate];	
    
	NSArray *addressresultarray=[managedobjectcontext executeFetchRequest:addressrequest error:nil];
    
    NSArray *dealeridsarray=[addressresultarray valueForKey:@"entityId"];
    NSMutableSet *idfromaddressset=[NSMutableSet setWithArray:dealeridsarray];
    
      
    //NSMutableArray *dealernamearray=[NSMutableArray arrayWithArray:arrayofrecord];
    
    [idfromnameset intersectSet:idfromaddressset];
    
    
    NSArray *finaldelaeridsarray=(NSArray *)[idfromnameset allObjects];
    
    
    NSFetchRequest *delaernamerequest=[[NSFetchRequest alloc] init];
    [delaernamerequest setEntity:dealerentity];
    NSPredicate *dealernamepredicate = [NSPredicate predicateWithFormat:@"dealerId IN %@",
                                        
                                        finaldelaeridsarray];
    [delaerrequest setPredicate:dealernamepredicate];
    [delaerrequest setFetchLimit:100];
    
    NSArray *finaldelaernamearray=[managedobjectcontext executeFetchRequest:delaerrequest error:nil];
    
    NSArray *delaernamearray=[finaldelaernamearray valueForKey:@"dealerName"];

    NSMutableArray *finaldealernamearray=[NSMutableArray arrayWithArray:delaernamearray];
    
	return finaldealernamearray;
    
}
*/

/*
//Fetch Expense and Inventory images
+(NSArray *)fetchexpenseandinvenotryimages:(NSString *)imagetype
{
    managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:@"Mobile_Images" inManagedObjectContext:managedobjectcontext];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isSynch==\"0\" AND imagetype==\"%@\"",imagetype]];
    
	[request setPredicate:predicates];	
    
	NSArray *arrayofrecord=[managedobjectcontext executeFetchRequest:request error:nil];
    
	return arrayofrecord;

}*/

#pragma mark - deleting all data

+ (void)deleteAllDataForEntity:(NSString *)entityName
{
    NSArray *arrData;
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityName inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    arrData = [[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    for(NSManagedObject *obj in arrData)
        [[CoreDataConfiguration sharedInstance].managedObjectContext deleteObject:obj];
    
    [[CoreDataConfiguration sharedInstance] saveContext];
}

+ (void)deleteAllmanagedobjectfromdatabaseExceptforintentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate
{
    // managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@!=\"%ld\"",attributename,(long)predicate]];
    [request setPredicate:predicates];
    
    NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    
    for(NSManagedObject *obj in arrayofrecord)
        [[CoreDataConfiguration sharedInstance].managedObjectContext deleteObject:obj];
    
    [[CoreDataConfiguration sharedInstance] saveContext];
}

#pragma mark - fetching all data



+(NSArray *)fetchDictionaryFromDatabaseforEntity:(NSString *)entityname
{
    NSArray *arrData = [[NSArray alloc]init];
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    arrData = [[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    return arrData;
}



#pragma mark general sorting fetch

+(NSArray *)fetchsortdataforentity:(NSString *)entityname  key:(NSString *)key   
{
	//managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSSortDescriptor *sorDescriptor=[[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sorDescriptor,nil];

    [request setSortDescriptors:sortDescriptors];
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;
}



#pragma mark General Fetch Managed Objects from database with unique result

+(NSArray *)fetchmanagedfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate  distinctrecordkey:(NSString *)keyvalue
{
	//managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    NSString *key=keyvalue;
    NSDictionary *entityProperties = [entity propertiesByName];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:key
                                                            ]]];
    
    [request setResultType:NSDictionaryResultType];
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
	[request setPredicate:predicates];	
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;
}

#pragma mark fetchuniqurkeyfromdatabase fetch method
+(NSArray *)fetchuniquekeyfromdatabase:(NSString *)entityname distinctrecordkey:(NSString *)keyvalue
{
   // managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    NSString *key=keyvalue;
    NSDictionary *entityProperties = [entity propertiesByName];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:key
                                                            ]]];
    
    [request setResultType:NSDictionaryResultType];
   
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;

}

#pragma mark General Fetch from database with unique result

+(NSArray *)fetchfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate  distinctrecordkey:(NSString *)keyvalue
{
	//managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    NSString *key=keyvalue;
    NSDictionary *entityProperties = [entity propertiesByName];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:key
                                                            ]]];

    [request setResultType:NSDictionaryResultType];
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
	[request setPredicate:predicates];	

	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;
}


/*
#pragma mark  Fetch all records with unique vin number

+(NSMutableArray *)fetchallrecordswithuniquevinnumber:(NSString *)entityname   distinctrecordkey:(NSString *)keyvalue
{
	managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:managedobjectcontext];
    NSString *key=keyvalue;
    NSDictionary *entityProperties = [entity propertiesByName];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:key
                                                            ]]];
    
    [request setResultType:NSDictionaryResultType];
    
	NSArray *arrayofrecord=[managedobjectcontext executeFetchRequest:request error:nil];
    
    NSMutableArray *resultarray=[arrayofrecord valueForKey:@"vinnumber"];
	return resultarray;
}

*/




#pragma mark update  inventory in database
+(NSManagedObject *)fetchmanagedobjectfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate 
{
   // managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%ld\"",attributename,(long)predicate]];
	[request setPredicate:predicates];	
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
   /* Mobile_PreInventory *preinventory=nil;
    
    if([arrayofrecord count]>0)
    {
        preinventory=[arrayofrecord lastObject];
    }
    else
    {
      //  preinventory=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:managedobjectcontext];
    }*/
    
    
    NSManagedObject *managedobject=nil;
    
    if([arrayofrecord count]>0)
    {
        managedobject=[arrayofrecord lastObject];
    }
    else
    {
          managedobject=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:managedobjectcontext];
    }

    
    return managedobject;
}

#pragma mark Insert/update  entity in database
+(NSManagedObject *)insertUpdatefromDatabaseforentity:(NSString *)entityname
{
    NSManagedObjectContext *managedobjectcontext=nil;
    managedobjectcontext=[CoreDataConfiguration sharedInstance].managedObjectContext;
	NSEntityDescription *entity=nil;
    entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:managedobjectcontext];
    
	NSFetchRequest *request=nil;
    request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
	NSArray *arrayofrecord=NULL;
    NSError *error;
    arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    NSManagedObject *managedobject=nil;
    
    if([arrayofrecord count]>0)
    {
        managedobject=[arrayofrecord lastObject];
    }
    else
    {
        managedobject=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:managedobjectcontext];
    }
    
    return managedobject;
}


+(NSManagedObject *)insertNewObjectforDatabaseforentity:(NSString *)entityname
{
    NSManagedObjectContext *managedobjectcontext=nil;
    managedobjectcontext=[CoreDataConfiguration sharedInstance].managedObjectContext;
    
    NSManagedObject *managedobject=nil;
    
    managedobject=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:managedobjectcontext];
    
    return managedobject;
}

#pragma mark update  Record in database
+(NSManagedObject *)fetchupdatemanagedobjectfromdatabaseforentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate 
{
    //[[Singleton sharedmysingleton] stoptimer];
    //NSManagedObjectContext *managedobjectcontext=nil;
   // managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=nil;
    entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
	NSFetchRequest *request=nil;
    request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=nil;
    predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
	[request setPredicate:predicates];	
    
	NSArray *arrayofrecord=NULL;
    NSError *error;
    arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:&error];
    
    NSManagedObject *managedobject=nil;
    
    if([arrayofrecord count]>0)
    {
        managedobject=[arrayofrecord lastObject];
    }
    else
    {
          managedobject=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    }
    
    return managedobject;
}

#pragma mark update Record for int in database
+(NSManagedObject *)fetchupdatemanagedobjectfromdatabaseforintentity:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSInteger )predicate 
{
   // managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%ld\"",attributename,(long)predicate]];
	[request setPredicate:predicates];	
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    
    NSManagedObject *managedobject=nil;
    
    if([arrayofrecord count]>0)
    {
        managedobject=[arrayofrecord lastObject];
    }
    else
    {
        managedobject=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:managedobjectcontext];
    }
    
    
    return managedobject;
}


+(NSArray *)fetchRecordsFromArrayforEntity:(NSString *)entityname resultArray:(NSArray *)resultArray attribute:(NSString *)attribute
{
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%K IN %@",attribute,resultArray];

    [request setPredicate:predicate];
    NSArray *finalResultArray=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    return finalResultArray;
}

+(NSArray *)fetchAttributeRecordsFromArrayforEntity:(NSString *)entityname attribute:(NSString *)attribute attributeValue:(NSString *)attributeValue
{
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%K CONTAINS %@",attribute,attributeValue];
    
    [request setPredicate:predicate];
    
    NSArray *finalResultArray=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    return finalResultArray;
}



#pragma mark General Fetch Managed Objects from database with unique result

+(NSArray *)fetchdistinctfromdatabaseforentity:(NSString *)entityname  resultArray:(NSArray *)resultArray attribute:(NSString *)attribute distinctrecordkey:(NSString *)keyvalue
{
	//managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    NSString *key=keyvalue;
    NSDictionary *entityProperties = [entity propertiesByName];
   // NSArray *allkeys=[entityProperties allKeys];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:key
                                                           ]]];
    
    [request setResultType:NSDictionaryResultType];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%K IN %@",attribute,resultArray];
    [request setPredicate:predicate];
    
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
	return arrayofrecord;
}

#pragma mark AND query
+(NSArray *)fetchwithtwoattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value
{
	//managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
    
    //  NSDictionary *entityProperties = [entity propertiesByName];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    // [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"modelID" ]]];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\" AND %@==\"%@\"",attribute1,attribute1value,attribute2,attribute2value]];
	[request setPredicate:predicates];	
    // [request setResultType:NSDictionaryResultType];
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];    
	
	return arrayofrecord;
}


+(NSManagedObject *)fetchManagedObjectwithtwoattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value
{
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
    
    //  NSDictionary *entityProperties = [entity propertiesByName];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    // [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"modelID" ]]];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\" AND %@==\"%@\"",attribute1,attribute1value,attribute2,attribute2value]];
	[request setPredicate:predicates];	
    // [request setResultType:NSDictionaryResultType];
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];    
	
    NSManagedObject *managedobject=nil;
    
    if([arrayofrecord count]>0)
    {
        managedobject=[arrayofrecord lastObject];
    }
    else
    {
        managedobject=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    }
    

	return managedobject;
}


+(NSArray *)fetchRecordswiththreeattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value  attribute3:(NSString *)attribute3 attribute3value:(NSString *)attribute3value
{
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\" AND %@==\"%@\" AND %@==\"%@\"",attribute1,attribute1value,attribute2,attribute2value,attribute3,attribute3value]];
    [request setPredicate:predicates];
    // [request setResultType:NSDictionaryResultType];
    NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    return arrayofrecord;
}



+(NSManagedObject *)fetchManagedObjectwiththreeattributes:(NSString *)entityname  attribute1:(NSString *)attribute1 attribute1value:(NSString *)attribute1value  attribute2:(NSString *)attribute2 attribute2value:(NSString *)attribute2value  attribute3:(NSString *)attribute3 attribute3value:(NSString *)attribute3value

{
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    
    
    //  NSDictionary *entityProperties = [entity propertiesByName];
    
	NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    // [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"modelID" ]]];
    
    NSPredicate *predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\" AND %@==\"%@\" AND %@==\"%@\"",attribute1,attribute1value,attribute2,attribute2value,attribute3,attribute3value]];
	[request setPredicate:predicates];	
    // [request setResultType:NSDictionaryResultType];
	NSArray *arrayofrecord=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];    
	
    NSManagedObject *managedobject=nil;
    
    if([arrayofrecord count]>0)
    {
        managedobject=[arrayofrecord lastObject];
    }
    else
    {
        managedobject=[NSEntityDescription insertNewObjectForEntityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    }
    
    
	return managedobject;
}


//not in query
+(NSArray *)fetchRecordsNotInFromArrayforEntity:(NSString *)entityname resultArray:(NSArray *)resultArray attribute:(NSString *)attribute
{
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:[CoreDataConfiguration sharedInstance].managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"NOT(%K IN %@)",attribute,resultArray];
    //NSPredicate *predicate=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"NOT(categoryID IN %@)",resultArray]];

    
    [request setPredicate:predicate];
    
    NSArray *finalResultArray=[[CoreDataConfiguration sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    
    return finalResultArray;
}


/*

#pragma mark get Image name and Image id   
+(NSString *)getImagenameandImageidfromdatabase:(NSString *)entityname  attributename:(NSString *)attributename   predicate:(NSString *)predicate
{
	managedobjectcontext=[Singleton sharedmysingleton].managedobjectcontext;
	NSEntityDescription *entity=[NSEntityDescription entityForName:entityname inManagedObjectContext:managedobjectcontext];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    NSPredicate *predicates=nil;
    
    if([attributename isEqualToString:@"imageTypeID"])
    {
        predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
        [request setPredicate:predicates];	
        NSArray *resultarray=[managedobjectcontext executeFetchRequest:request error:nil];    
        NSString *imagetypename=nil;
        if([resultarray count]>0)
        {
            imagetypename=[[NSString alloc] init];
            Mobile_ImageType *mobileimageentity=nil;
            mobileimageentity=[resultarray lastObject];
            imagetypename=mobileimageentity.imageType;
            
        }
        return imagetypename;
        
    }
    
    if([attributename isEqualToString:@"imageType"])
    {
        predicates=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==\"%@\"",attributename,predicate]];
        [request setPredicate:predicates];	
        NSArray *resultarray=[managedobjectcontext executeFetchRequest:request error:nil];    
        NSString *imagetypeid=nil;
        if([resultarray count]>0)
        {
            imagetypeid=[[NSString alloc] init];
            Mobile_ImageType *mobileimageentity=nil;
            mobileimageentity=[resultarray lastObject];
            imagetypeid=mobileimageentity.imageTypeID;
            
        }
        return imagetypeid;
        
    }
    
    
    return nil;
}
*/




@end
