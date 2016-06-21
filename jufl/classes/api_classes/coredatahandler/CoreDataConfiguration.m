    //
//  CoreDataConfiguration.m
//  MyScene
//
//  Created by Sashi Bhushan on 20/04/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import "CoreDataConfiguration.h"

#define kManagedObjectContext @"ManagedObjectContext"

@interface CoreDataConfiguration ()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;


@end

@implementation CoreDataConfiguration
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        if(sharedInstance)
        {
        }
    });
    return sharedInstance;
}

- (void)clearCoreDataBase { 
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"JUFL.sqlite"];
    
    NSPersistentStore *persistanceStore = [self.persistentStoreCoordinator persistentStoreForURL:storeURL];
    NSError *error;
    [self.persistentStoreCoordinator removePersistentStore:persistanceStore error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    [self clearContext];
    [self managedObjectContext];
}


#pragma mark - Core Data stack

- (void)clearContext
{
    _managedObjectContext  = nil ;
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil ;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appster.MiVista" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"JUFL" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    @synchronized(self) {
        if (_persistentStoreCoordinator != nil) {
            return _persistentStoreCoordinator;
        }
        
        // Create the coordinator and store
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"JUFL.sqlite"];
        NSError *error = nil;
        NSString *failureReason = @"There was an error creating or loading the application's saved data.";
        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                   NSInferMappingModelAutomaticallyOption : @(YES)};
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            // Report any error we got.
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
            dict[NSLocalizedFailureReasonErrorKey] = failureReason;
            dict[NSUnderlyingErrorKey] = error;
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

            abort();
}
            }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    
    if(![[NSThread currentThread] isMainThread])
    {
        NSManagedObjectContext *tempMOC = (NSManagedObjectContext *)[[NSThread currentThread] threadDictionary][kManagedObjectContext];
        if(!tempMOC)
        {
            tempMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
            if (!coordinator) {
                return nil;
            }
            [tempMOC setPersistentStoreCoordinator:coordinator];
            [[[NSThread currentThread] threadDictionary] setObject:tempMOC forKey:kManagedObjectContext];

        }
        return tempMOC;

    }
    else
    {
        if (_managedObjectContext != nil) {
            return _managedObjectContext;
        }

    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if(![[NSThread currentThread] isMainThread])
    {
        managedObjectContext = (NSManagedObjectContext *)[[NSThread currentThread] threadDictionary][kManagedObjectContext];
    }

    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
