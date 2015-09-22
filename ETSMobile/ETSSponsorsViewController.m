//
//  ETSSponsorsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSponsorsViewController.h"
#import "ETSSynchronization.h"
#import "ETSCoreDataHelper.h"
#import "NSURLRequest+API.h"
#import "ETSPartner.h"
#import "UIImageView+WebCache.h"

@interface ETSSponsorsViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ETSSponsorsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)startRefresh:(id)sender
{
    NSError *error;
    [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Partner" inManagedObjectContext:self.managedObjectContext];
    [self.synchronization synchronize:&error];
    if (error != nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"SponsorIdentifier";
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForPartners];
    synchronization.entityName = @"Partner";
    synchronization.compareKey = @"name";
    synchronization.objectsKeyPath = @"data";
    synchronization.appletsServer = YES;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if ([[[[self.fetchedResultsController sections] firstObject] objects] count] == 0) {
        [self startRefresh:self];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Partner" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 24;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self.collectionView reloadData];
    
    return _fetchedResultsController;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSPartner *partner = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:partner.imageurl]];
    imageView.frame = CGRectIntegral(CGRectMake(0, 0, cell.bounds.size.width-5, cell.bounds.size.height-5));
    imageView.center = CGPointMake(cell.bounds.size.width/2, cell.bounds.size.height/2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [cell addSubview:imageView];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    if (![managedObject isKindOfClass:[ETSPartner class]]) return;
}

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ETSPartner *partner = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CGFloat width = self.collectionView.bounds.size.width * (CGFloat)[partner.index floatValue] / 7;
    CGFloat height = width/2;
    
    return CGSizeMake(width, height);
}

@end
