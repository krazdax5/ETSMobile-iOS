//
//  ETSInternshipViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-25.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSInternshipViewController.h"
#import "ETSInternshipDetailsViewController.h"
#import "ETSInternship.h"

@interface ETSInternshipViewController ()

@end

@implementation ETSInternshipViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForInternship];
    synchronization.entityName = @"Internship";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"";
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.cellIdentifier = @"InternshipIdentifier";
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Internship"];
	fetchRequest.fetchBatchSize = 10;
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"favorite" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"favorite" cacheName:nil];
	self.fetchedResultsController = aFetchedResultsController;
	_fetchedResultsController.delegate = self;
    
	NSError *error;
	if (![_fetchedResultsController performFetch:&error]) {
		// FIXME: Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
	return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSInternship *internship = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = internship.employer;
    cell.detailTextLabel.text = internship.title;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSInternship *internship = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return [internship.favorite boolValue] == YES ? NSLocalizedString(@"Favoris", nil) : [internship.favorite boolValue] == NO ? NSLocalizedString(@"Toutes les autres offres", nil) : nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((ETSInternshipDetailsViewController *)segue.destinationViewController).internship = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
}

@end
