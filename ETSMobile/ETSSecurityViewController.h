//
//  ETSSecurityViewController.h
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-02-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import <MapKit/MapKit.h>

@interface ETSSecurityViewController : UITableViewController

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end