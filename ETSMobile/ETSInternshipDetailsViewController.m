//
//  ETSInternshipDetailsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-25.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSInternshipDetailsViewController.h"
#import "UIColor+Styles.h"
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
    
    self.navigationController.toolbar.barTintColor = [UIColor naviguationBarTintColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 5;
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
            cell.textLabel.text = @"Entreprise";
            cell.detailTextLabel.text = self.internship.employer;
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Poste";
            cell.detailTextLabel.text = self.internship.title;
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.internship.employerType;
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = @"Lieu";
            cell.detailTextLabel.text = self.internship.city;
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = @"Date limite";
            cell.detailTextLabel.text = @"7 mai 2014 à 15h00";
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = self.internship.summary;
        cell.detailTextLabel.text = nil;
    } else if (indexPath.section == 2) {
        cell.textLabel.text = self.internship.employerDescription;
        cell.detailTextLabel.text = nil;
    }

    return cell;
}
- (IBAction)addToFavorite:(id)sender
{
    self.internship.favorite = [NSNumber numberWithBool:YES];
    [self.internship.managedObjectContext save:nil];
}

- (IBAction)applyToJob:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Vous êtes sur le point de postuler pour le poste %@ chez %@.", self.internship.title, self.internship.employer] delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Confirmer", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Sommaire";
    else if (section == 1) return @"Description du poste";
    else if (section == 2) return @"Description de l'entreprise";
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return 44;
    
    return 300;
}
@end
