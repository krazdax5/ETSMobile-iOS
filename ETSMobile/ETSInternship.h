//
//  ETSInternship.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-26.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSInternship : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * employer;
@property (nonatomic, retain) NSString * employerDescription;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * employerType;

@end
