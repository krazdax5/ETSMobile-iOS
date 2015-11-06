//
//  TodayViewController.m
//  Today
//
//  Created by Maxime Mongeau on 2015-11-03.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "ETSTodayViewController.h"
#import "ETSTodayTableViewCell.h"
#import "ETSCalendar.h"
#import "NSDate+Timezone.h"
#import <NotificationCenter/NotificationCenter.h>

@interface ETSTodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *courseList;
@end

@implementation ETSTodayViewController

static NSString * const kCellIdentifier = @"ETSTodayCell";

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
    
    cell.coursLabel.text = @"No course today";
    cell.heuresLabel.text = @"";
    cell.localLabel.text = @"";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.courseList count] > 0) {
        return self.courseList.count;
    }
    return 1;
}

@end
