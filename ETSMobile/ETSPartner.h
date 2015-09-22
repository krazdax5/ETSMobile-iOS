//
//  ETSPartner.h
//  ETSMobile
//
//  Created by Thomas Durand on 21/09/2015.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ETSPartner: NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * imageurl;

@end
