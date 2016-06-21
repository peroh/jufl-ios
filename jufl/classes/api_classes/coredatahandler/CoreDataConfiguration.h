//
//  CoreDataConfiguration.h
//  MyScene
//
//  Created by Sashi Bhushan on 20/04/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataConfiguration : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (void)clearContext;
- (void)clearCoreDataBase;
+ (instancetype)sharedInstance;

- (NSURL *)applicationDocumentsDirectory;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end
