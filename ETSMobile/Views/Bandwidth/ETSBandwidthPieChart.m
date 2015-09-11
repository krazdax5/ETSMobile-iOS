//
//  ETSBandwidthPieChart.m
//  ETSMobile
//
//  Created by Thomas Durand on 11/09/2015.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "ETSBandwidthPieChart.h"

@implementation ETSBandwidthPieChart
-(void)recompute {
    self.outerCircleRadius = CGRectGetHeight(self.bounds) / 2;
    self.innerCircleRadius = CGRectGetHeight(self.bounds) / 6;
}
@end
