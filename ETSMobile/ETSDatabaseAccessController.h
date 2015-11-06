//
//  ETSDatabaseAccessController.h
//  ETSMobile
//
//  Created by Maxime Mongeau on 2015-11-05.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ETSDatabaseAccessController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedController;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationGroupDocumentsDirectory;

@end
