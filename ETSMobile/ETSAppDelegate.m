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
    menuViewController.managedObjectContext = [[ETSDatabaseAccessController sharedController] managedObjectContext];
    
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    if ([url.scheme isEqualToString:@"etsmobile"]) {
        //TODO -> Add support when opening Horaire url
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
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

- (NSManagedObjectContext *)managedObjectContext {
    return [[ETSDatabaseAccessController sharedController] managedObjectContext];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return [[ETSDatabaseAccessController sharedController] persistentStoreCoordinator];
}

@end
