//
//  ETSTodayTableViewCell.h
//  ETSMobile
//
//  Created by Maxime Mongeau on 2015-11-03.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSTodayTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *coursLabel;
@property (weak, nonatomic) IBOutlet UILabel *heuresLabel;
@property (weak, nonatomic) IBOutlet UILabel *localLabel;

@end
