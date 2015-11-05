//
//  ETSAppDelegate.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-18.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSAppDelegate.h"

#import "MSDynamicsDrawerViewController.h"
#import "ETSMenuViewController.h"
#import "UIColor+Styles.h"
#import "NSURLRequest+API.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ETSNewsViewController.h"
#import "ETSCoursesViewController_iPad.h"
#import "ETSCourseDetailViewController.h"
#import "ETSRadioViewController.h"
#import "ETSWebViewViewController.h"
#import "ETSSecurityViewController.h"
#import "ETSDirectoryViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <SupportKit/SupportKit.h>


@implementation ETSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor naviguationBarTintColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    self.dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.window.rootViewController;
    self.dynamicsDrawerViewController.screenEdgePanCancelsConflictingGestures = NO;
    self.dynamicsDrawerViewController.paneViewSlideOffAnimationEnabled = NO;
    self.dynamicsDrawerViewController.gravityMagnitude = 6;
    self.dynamicsDrawerViewController.bounceElasticity = 0;
    self.dynamicsDrawerViewController.bounceMagnitude = 0;
    self.dynamicsDrawerViewController.elasticity = 0;
    self.dynamicsDrawerViewController.paneDragRequiresScreenEdgePan = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerScaleStyler styler], [MSDynamicsDrawerFadeStyler styler], [MSDynamicsDrawerParallaxStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.dynamicsDrawerViewController.paneView.clipsToBounds = YES;
    }
    
    ETSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    menuViewController.managedObjectContext = self.managedObjectContext;
    
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    
    // Transition to the first view controller
    [menuViewController transitionToViewController:ETSPaneViewControllerTypeNews];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.dynamicsDrawerViewController;
    [self.window makeKeyAndVisible];

    // Crashlytics
    [Fabric with:@[CrashlyticsKit]];
    
    // SupportKit
    NSString* apikey = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SupportKitApiKey"];
    SKTSettings* settings = [SKTSettings settingsWithAppToken:apikey];
    settings.conversationStatusBarStyle = UIStatusBarStyleLightContent;
    settings.conversationAccentColor = [UIColor naviguationBarTintColor];
    settings.enableGestureHintOnFirstLaunch = NO;
    settings.enableAppWideGesture = NO;
    
    [SupportKit initWithSettings:settings];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
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
