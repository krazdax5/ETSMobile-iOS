//
//  TodayViewController.h
//  Today
//
//  Created by Maxime Mongeau on 2015-11-03.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSTodayViewController : UIViewController
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end
