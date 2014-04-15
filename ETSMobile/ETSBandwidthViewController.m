//
//  ETSBandwidthViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-12-31.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSBandwidthViewController.h"
#import "ETSBandwidth.h"
#import "ETSBandwidthCell.h"
#import "ETSLoginView.h"
#import "ETSCoreDataHelper.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>

@interface ETSBandwidthViewController ()
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, weak) IBOutlet ETSLoginView *loginView;
@property (nonatomic, strong) NSNumber *usedBandwidth;
@property (nonatomic, strong) NSNumber *limitBandwidth;
@property (weak, nonatomic) IBOutlet UILabel *phaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *apartmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *usageLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *usageProgressView;
@end

@implementation ETSBandwidthViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (IBAction)panLeftMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}


- (void)viewApartmentAlert
{
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    self.loginView.layer.cornerRadius = 7;
    [alertView setContainerView:self.loginView];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", @"Annuler", nil]];
    [alertView setUseMotionEffects:TRUE];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];

        NSString *month = [@([[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]] month]) stringValue];
        self.synchronization.request = [NSURLRequest requestForBandwidthWithMonth:month residence:self.loginView.apartmentTextField.text phase:self.loginView.phaseTextField.text];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.loginView.apartmentTextField.text forKey:@"apartment"];
        [userDefaults setObject:self.loginView.phaseTextField.text forKey:@"phase"];
        self.phaseLabel.text = [NSString stringWithFormat:@"Phase %@", self.loginView.phaseTextField.text];
        self.apartmentLabel.text = [NSString stringWithFormat:@"Appartement %@", self.loginView.apartmentTextField.text];
        NSError *error;
        [self.synchronization synchronize:&error];
    }
    
    [alertView close];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"BANDWIDTH_VIEWCONTROLLER"];
    
    NSString *month = [@([[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]] month]) stringValue];
    
    self.cellIdentifier = @"BandwidthIdentifier";
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.entityName = @"Bandwidth";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"query.results.table";
    synchronization.dateFormatter = self.dateFormatter;
    synchronization.predicate = [NSPredicate predicateWithFormat:@"month ==[c] %@", month];
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.groupingSeparator = @" ";
    self.formatter.groupingSize = 3;
    self.formatter.usesGroupingSeparator = YES;
    self.formatter.maximumFractionDigits = 2;
    self.formatter.minimumFractionDigits = 2;
    self.formatter.minimumIntegerDigits = 1;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"Bande passante";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewApartmentAlert)];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apartment = [userDefaults stringForKey:@"apartment"];
    NSString *phase = [userDefaults stringForKey:@"phase"];
    
    if ([apartment length] == 0 || [phase length] == 0) {
        [self viewApartmentAlert];
        self.dataNeedRefresh = NO;
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        self.tableView.tableHeaderView.hidden = YES;
    }
    else {
        synchronization.request = [NSURLRequest requestForBandwidthWithMonth:month residence:apartment phase:phase];
        self.phaseLabel.text = [NSString stringWithFormat:@"Phase %@", phase];
        self.apartmentLabel.text = [NSString stringWithFormat:@"Appartement %@", apartment];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
        df.dateFormat = @"LLLL yyyy";
        self.dateLabel.text = [NSString stringWithFormat:@"Consommation, %@ :", [df stringFromDate:[NSDate date]]];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 10;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"port" ascending:YES]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSBandwidth *bandwidth = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    NSDateFormatter *titleFormatter = [[NSDateFormatter alloc] init];
    titleFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    titleFormatter.dateFormat = @"cccc, d LLLL yyyy";
    return [titleFormatter stringFromDate:bandwidth.date];
}

- (void)configureCell:(ETSBandwidthCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSBandwidth *bandiwdth = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.portLabel.text = bandiwdth.port;
    cell.uploadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬆︎)", [self.formatter stringFromNumber:bandiwdth.upload]];
    cell.downloadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬇︎)", [self.formatter stringFromNumber:bandiwdth.download]];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if (!objects || [objects isKindOfClass:[NSNull class]]) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        self.tableView.tableHeaderView.hidden = YES;
        return nil;
    }
    
    NSMutableArray *entries = [NSMutableArray array];
    
    NSArray *tables = (NSArray *)objects;

    if ([tables count] < 2) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        self.tableView.tableHeaderView.hidden = YES;
        return nil;
    }
    
    NSArray *days = (tables[0])[@"tr"];

    NSInteger i = 0;
    for (NSDictionary * day in days) {
        if (i++ == 0) continue;
        if ([day[@"td"] count] != 4) continue;
        
        NSString *date = day[@"td"][1][@"p"];
        if ([date isEqualToString:@"Journée en cours"]) date = [self.dateFormatter stringFromDate:[NSDate date]];
        
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self.dateFormatter dateFromString:date]];
        
        entry[@"port"] = day[@"td"][0][@"p"];
        entry[@"date"] = date;
        entry[@"upload"] = day[@"td"][2][@"p"];
        entry[@"download"] = day[@"td"][3][@"p"];
        entry[@"month"] = [@([components month]) stringValue];
        entry[@"id"] = [NSString stringWithFormat:@"%@-%@", day[@"td"][0][@"p"], date];
        [entries addObject:entry];
    }
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.decimalSeparator = @".";
    self.usedBandwidth = [f numberFromString:[days lastObject][@"td"][1][@"p"]];
    self.limitBandwidth = [f numberFromString:tables[1][@"tr"][1][@"td"][1][@"p"]];

    NSNumber *used = @([self.usedBandwidth floatValue]/1024);
    NSNumber *limit = @([self.limitBandwidth floatValue]/1024);
    self.usageLabel.text = [NSString stringWithFormat:@"%@ Go sur %@ Go", [self.formatter stringFromNumber:used], [self.formatter stringFromNumber:limit]];
    self.usageProgressView.progress = [self.usedBandwidth floatValue] / [self.limitBandwidth floatValue];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    df.dateFormat = @"LLLL yyyy";
    self.dateLabel.text = [NSString stringWithFormat:@"Consommation, %@ :", [df stringFromDate:[NSDate date]]];
    
    self.tableView.tableHeaderView.hidden = NO;
    
    return entries;
}

@end
