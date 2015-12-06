//
//  TodayViewController.m
//  Today
//
//  Created by Maxime Mongeau on 2015-11-03.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "ETSTodayViewController.h"
#import "ETSTodayTableViewCell.h"
#import "ETSFooterTableViewCell.h"
#import "ETSCalendar.h"
#import "NSDate+Timezone.h"
#import <NotificationCenter/NotificationCenter.h>

@interface ETSTodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *courseList;
@property (nonatomic) NSUInteger numberOfCells;
@end

@implementation ETSTodayViewController

static NSString * const kCellIdentifier = @"ETSTodayCell";
static NSString * const kFooterCellIdentifier = @"TodayFooterCell";
static NSString * const kEmptyCellIdentifier = @"TodayEmptyCell";

#pragma mark - View Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    [self.tableView setRowHeight:60];
    [self widgetPerformUpdateWithCompletionHandler:^(NCUpdateResult result) {
        if (result == NCUpdateResultNewData) {
            [self.tableView reloadData];
        }
    }];
    [self setPreferredContentSize:CGSizeMake(0, [self.tableView numberOfRowsInSection:0] * [self.tableView rowHeight])];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Calendar"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:components];
    components.day ++;
    NSDate *tomorrow = [calendar dateFromComponents:components];
    NSError *error = nil;
    NSArray *fetchedCourses;
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(start >= %@) AND (start <= %@)", today, tomorrow]];
    fetchedCourses = [[[ETSDatabaseAccessController sharedController] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"Unexpected error while fetching courses in extension %@, %@", error, [error userInfo]);
        completionHandler(NCUpdateResultFailed);
        return;
    }
    
    if (fetchedCourses && fetchedCourses != self.courseList) {
        self.courseList = fetchedCourses;
        completionHandler(NCUpdateResultNewData);
        return;
    }
    
    completionHandler(NCUpdateResultNoData);
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Course list is empty
    if (self.courseList.count == 0) {
        UITableViewCell *emptyViewCell = [self.tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier];
        emptyViewCell.separatorInset = UIEdgeInsetsMake(0.f, emptyViewCell.bounds.size.width, 0.f, 0.f);
        return emptyViewCell;
    }
    
    //End of the course list
    if (indexPath.row == self.numberOfCells - 1 ) {
            ETSFooterTableViewCell *footerViewCell = [self.tableView dequeueReusableCellWithIdentifier:kFooterCellIdentifier];
            footerViewCell.separatorInset = UIEdgeInsetsMake(0.f, footerViewCell.bounds.size.width, 0.f, 0.f);
        [footerViewCell.showScheduleBtn addTarget:self action:@selector(scheduleBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            return footerViewCell;
    }
    
    ETSTodayTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    ETSCalendar *course = [self.courseList objectAtIndex:indexPath.row];
    if (course) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSDate *utcStartDate = [course.start toUTCTime];
        NSDate *utcEndDate = [course.end toUTCTime];
        NSString *startTime = [dateFormatter stringFromDate:utcStartDate];
        NSString *endTime = [dateFormatter stringFromDate:utcEndDate];
        
        cell.coursLabel.text = course.course;
        cell.heuresLabel.text = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
        cell.localLabel.text = course.room;
        return cell;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.courseList count] > 0) {
        self.numberOfCells = self.courseList.count + 1;
        return self.numberOfCells;
    }
    return 1;
}

- (void) scheduleBtnPressed:(id) obj {
    NSURL *pjURL = [NSURL URLWithString:@"etsmobile://horaire"];
    [self.extensionContext openURL:pjURL completionHandler:nil];
}

@end
