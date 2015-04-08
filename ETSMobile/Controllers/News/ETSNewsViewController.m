//
//  ETSNewsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-08-19.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSNewsViewController.h"
#import "ETSNewsSourceViewController.h"
#import "ETSNewsCell.h"
#import "ETSNewsEmptyCell.h"
#import "NSURL+Document.h"
#import "ETSNews.h"
#import "NSString+HTML.h"
#import "GTMNSString+HTML.h"
#import "UIImageView+WebCache.h"

@implementation ETSNewsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)updateDefaultNewsSource
{
    NSArray *sources = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NewsSources" ofType:@"plist"]];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.entityName = @"NewsSource";
    synchronization.compareKey = @"id";
    synchronization.ignoredAttributes = @[@"enabled"];
    synchronization.managedObjectContext = self.managedObjectContext;
    
    NSError *error = nil;
    [synchronization synchronizeJSONArray:sources error:&error];
    if (![self.managedObjectContext save:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSArray *)enabledSources
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"NewsSource"];
    request.predicate = [NSPredicate predicateWithFormat:@"enabled == 1"];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"News"];
    
    fetchRequest.fetchBatchSize = 5;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ymdDate" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"ymdDate" cacheName:nil];
    
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    #ifdef __USE_BUGSENSE
    [[Mint sharedInstance] leaveBreadcrumb:@"NEWS_VIEWCONTROLLER"];
    #endif
    
    self.tableView.estimatedRowHeight = 133.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self updateDefaultNewsSource];
    
    self.cellIdentifier = @"NewsIdentifier";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForNewsWithSources:[self enabledSources]];
    synchronization.entityName = @"News";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"data";
    synchronization.dateFormatter = dateFormatter;
    synchronization.appletsServer = YES;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.synchronization.request = [NSURLRequest requestForNewsWithSources:[self enabledSources]];
    [super viewWillAppear:animated];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    NSMutableArray *news = [NSMutableArray array];
    
    NSDateFormatter *ymdFormatter = [NSDateFormatter new];
    [ymdFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [ymdFormatter setDateFormat:@"yyyy'-'MM'-'dd"];

    NSArray *keys = [((NSDictionary *)objects) allKeys];
    
    for (NSString *key in keys) {
        
        for (NSDictionary *object in objects[key]) {
            NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithDictionary:object];
<<<<<<< HEAD
            
<<<<<<< HEAD:ETSMobile/ETSNewsViewController.m
            NSDate *date = [self.synchronization.dateFormatter dateFromString:object[@"updated_time"]];
            NSString *dateString = [ymdFormatter stringFromDate:date];
=======
            NSDate *date = [self.synchronization.dateFormatter dateFromString:object[@"updated_time"]];
            
            NSString *dateString = [ymdFormatter stringFromDate:date];

>>>>>>> Bugfixes
            if (dateString) {
                entry[@"ymdDate"] = dateString;
                [news addObject:entry];
            }
<<<<<<< HEAD
        }
=======
  /*          if ([entry[@"message"] isKindOfClass:[NSString class]] && [entry[@"message"] length] > 0) {
                entry[@"title"] = entry[@"message"];
            }*/
            [news addObject:entry];
=======
>>>>>>> Bugfixes
        }
        
>>>>>>> Conversion pour iOS 8 seulement.:ETSMobile/Controllers/News/ETSNewsViewController.m
    }
    return news;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Partager" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                  {
                                      NSArray *activityItems = @[news.title, [NSURL URLWithString:news.link]];
                                      UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                                      activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                      
                                      [self presentViewController:activityViewController animated:YES completion:nil];
                                  }];
    share.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    UITableViewRowAction *open = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Ouvrir" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:news.link]];
                                     }];
    open.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    
    return @[open, share];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.shouldRemoveFetchedDelegate = NO;
    if ([segue.identifier isEqualToString:@"SourcesSegue"]) {
        ETSNewsSourceViewController *destinationController = (ETSNewsSourceViewController *)segue.destinationViewController;
        destinationController.managedObjectContext = self.managedObjectContext;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell = nil;
    if (news.thumbnailURL && news.thumbnailURL.length > 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NewsEmptyIdentifier" forIndexPath:indexPath];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ETSNewsCell class]]) {
        ((ETSNewsCell *)cell).contentTextView.text = news.content;
        ((ETSNewsCell *)cell).contentTextView.textColor = [UIColor blackColor];
        ((ETSNewsCell *)cell).contentTextView.textContainer.exclusionPaths = @[[UIBezierPath bezierPathWithRect:((ETSNewsCell *)cell).thumbnailView.bounds]];
        ((ETSNewsCell *)cell).authorLabel.text = news.author;
        ((ETSNewsCell *)cell).thumbnailView.image = nil;
<<<<<<< HEAD
<<<<<<< HEAD
        [((ETSNewsCell *)cell).thumbnailView sd_setImageWithURL:[NSURL URLWithString:news.thumbnailURL]];
=======
        
        [((ETSNewsCell *)cell).thumbnailView sd_setImageWithURL:[NSURL URLWithString:news.thumbnailURL]];
        
>>>>>>> Utilisation de la cache pour les images des actualités.
        ((ETSNewsCell *)cell).thumbnailView.clipsToBounds = YES;
=======
        [((ETSNewsCell *)cell).thumbnailView sd_setImageWithURL:[NSURL URLWithString:news.thumbnailURL]];
                ((ETSNewsCell *)cell).thumbnailView.clipsToBounds = YES;
>>>>>>> Nouveau format des nouvelles.
    } else if ([cell isKindOfClass:[ETSNewsEmptyCell class]]) {
        ((ETSNewsEmptyCell *)cell).contentTextView.text = news.content;
        ((ETSNewsCell *)cell).contentTextView.textColor = [UIColor blackColor];
        ((ETSNewsEmptyCell *)cell).authorLabel.text = news.author;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];

    NSDateFormatter *ymdFormatter = [NSDateFormatter new];
    ymdFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [ymdFormatter dateFromString:sectionInfo.name];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    dateFormatter.locale = locale;
    dateFormatter.dateFormat = @"EEEE, d MMMM YYYY";

    return [dateFormatter stringFromDate:date];
}

@end
