//
//  TodayViewController.m
//  Today
//
//  Created by Maxime Mongeau on 2015-11-03.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "ETSTodayViewController.h"
#import "ETSTodayTableViewCell.h"
#import <NotificationCenter/NotificationCenter.h>

@interface ETSTodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ETSTodayViewController

static NSString * const kCellIdentifier = @"ETSTodayCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setRowHeight:44];
    [self.tableView reloadData];
    [self setPreferredContentSize:CGSizeMake(0, [self.tableView numberOfRowsInSection:0] * [self.tableView rowHeight])];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    completionHandler(NCUpdateResultNewData);
}

// MARK: UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ETSTodayTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.coursLabel.text = @"LOG321-02";
    cell.heuresLabel.text = @"12:00 - 13:12";
    cell.localLabel.text = @"A-1234";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

@end
