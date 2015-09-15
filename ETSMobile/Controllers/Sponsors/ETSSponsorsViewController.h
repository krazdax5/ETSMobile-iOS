//
//  ETSSponsorsViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ETSSponsor) {
    ETSSponsorETS,
    ETSSponsorBell,
    ETSSponsorAEETS,
    ETSSponsorFDETS,
    ETSSponsorGitHub,
    ETSSponsorBugSense,
    ETSSponsorAtlassian
};

@interface ETSSponsorsViewController : UICollectionViewController

@end