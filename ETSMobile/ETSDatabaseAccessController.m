//
//  ETSDatabaseAccessController.m
//  ETSMobile
//
//  Created by Maxime Mongeau on 2015-11-05.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "ETSDatabaseAccessController.h"

@implementation ETSDatabaseAccessController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedController {
    static ETSDatabaseAccessController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ETSMobile" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    BOOL needMigration = NO;
    BOOL needCleanUp = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dataBaseName = @"ETSMobile24042015.sqlite";
    NSPersistentStore *store;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataBaseName];
    NSURL *groupURL = [[self applicationGroupDocumentsDirectory] URLByAppendingPathComponent:dataBaseName];
    NSDictionary *migrationOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                       NSInferMappingModelAutomaticallyOption: @YES};
    NSURL *targetURL = nil;
    NSError *error = nil;
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    if ([fm fileExistsAtPath:[storeURL path]]) {
        needMigration = YES;
        targetURL = storeURL;
    }
    
    if ([fm fileExistsAtPath:[groupURL path]]) {
        needMigration = NO;
        targetURL = groupURL;
        if ([fm fileExistsAtPath:[storeURL path]]) {
            needCleanUp = YES;
        }
    }
    
    if (!targetURL) {
        targetURL = groupURL;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:targetURL options:nil error:&error];
    if (!store) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if (needMigration) {
        NSError *error = nil;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:_persistentStoreCoordinator];
        [_persistentStoreCoordinator migratePersistentStore:store toURL:groupURL options:migrationOptions withType:NSSQLiteStoreType error:&error];
        if (error != nil) {
            NSLog(@"Error while migrating data to the group url %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    if (needCleanUp) {
        NSError *error = nil;
        [fm removeItemAtURL:storeURL error:&error];
        if (error != nil) {
            NSLog(@"Error while removing old database %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationGroupDocumentsDirectory {
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.ca.etsmtl.applets.ETSMobile"];
}

@end
