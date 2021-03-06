//
//  Recipe.h
//  medikit
//
//  Created by Estudiante on 02/09/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient;

@interface Recipe : NSManagedObject

@property (nonatomic, retain) NSNumber * dosisAmount;
@property (nonatomic, retain) NSNumber * dosisInterval;
@property (nonatomic, retain) NSNumber * dosisPerDay;
@property (nonatomic, retain) NSDate * dosisStartTime;
@property (nonatomic, retain) NSString * dosisType;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * durationTotal;
@property (nonatomic, retain) NSString * durationType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Patient *patientParent;

@end
