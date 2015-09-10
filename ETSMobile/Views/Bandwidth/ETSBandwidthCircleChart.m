//
//  ETSBandwidthCircleChart.m
//  ETSMobile
//
//  Created by Thomas Durand on 09/09/2015.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "ETSBandwidthCircleChart.h"
#import "UIColor+Styles.h"
#import <math.h>

@implementation ETSBandwidthCircleChart

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
}

-(void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat width = 30.0;
    CGFloat radius = (center.x-width);
    
    // Drawing background
    UIBezierPath *background = [UIBezierPath bezierPathWithArcCenter:center radius: radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    [[UIColor grayColor] setStroke];
    background.lineWidth = width;
    [background stroke];
    
    // Drawing used
    if (self.used && self.limit) {
        CGFloat max = (self.used/self.limit);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius: radius startAngle: [self getInitialAngle] endAngle:[self getAngleForRate:max] clockwise:YES];
        [[UIColor naviguationBarTintColor] setStroke];
        path.lineWidth = width;
        [path stroke];
    }
    
    // Drawing ideal quota marker
    CGPoint beginPoint = CGPointMake(center.x + (radius-width)*cos([self getAngleForRate:self.ideal/self.limit]),
                                     center.y + (radius-width)*sin([self getAngleForRate:self.ideal/self.limit]));
    CGPoint endPoint = CGPointMake(center.x + (radius+width)*cos([self getAngleForRate:self.ideal/self.limit]),
                                   center.y + (radius+width)*sin([self getAngleForRate:self.ideal/self.limit]));
    
    UIBezierPath* marker = [UIBezierPath bezierPath];
    [marker moveToPoint:beginPoint];
    [marker addLineToPoint:endPoint];
    
    marker.lineWidth = 1;
    [marker stroke];
}

-(CGFloat)getAngleForRate:(CGFloat)rate {
    return (rate*2*M_PI)-M_PI_2;
}

-(CGFloat)getInitialAngle {
    return [self getAngleForRate:0];
}

@end