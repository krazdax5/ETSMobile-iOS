//
//  ETSInternshipDetailsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-25.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSInternshipDetailsViewController.h"
#import <MapKit/MapKit.h>

@interface ETSInternshipDetailsViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation ETSInternshipDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.internship.employer;

    CLLocationCoordinate2D coordinate = {.latitude =  [self.internship.latitude floatValue], .longitude = [self.internship.longitude floatValue]};
    MKCoordinateSpan span = {.latitudeDelta = 0.05, .longitudeDelta = 0.05};
    MKCoordinateRegion region = {coordinate, span};
    [self.mapView setRegion:region];
    
	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = self.internship.employer;

	[self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 4;
    else if (section == 1) return 1;
    else if (section == 2) return 1;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) cell = [tableView dequeueReusableCellWithIdentifier:@"InternshipInformationIdentifier" forIndexPath:indexPath];
    else cell = [tableView dequeueReusableCellWithIdentifier:@"InternshipSummaryIdentifier" forIndexPath:indexPath];
        
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = self.internship.summary;
    } else if (indexPath.section == 2) {
        cell.textLabel.text = self.internship.employerDescription;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return 44;
    
    NSString *text = (indexPath.section == 1) ? self.internship.summary : self.internship.employerDescription;

    return [text boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:
                                                                                                                                  [UIFont systemFontOfSize:14.0f]} context:nil].size.height;
}
@end
