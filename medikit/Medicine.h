//
//  Medicine.h
//  medikit
//
//  Created by Nixon Espinoza on 12/25/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipe;

@interface Medicine : NSManagedObject

@property (nonatomic, retain) NSString * comercialName;
@property (nonatomic, retain) NSString * genericName;
@property (nonatomic, retain) NSSet *recipeMedicine;
@end

@interface Medicine (CoreDataGeneratedAccessors)

- (void)addRecipeMedicineObject:(Recipe *)value;
- (void)removeRecipeMedicineObject:(Recipe *)value;
- (void)addRecipeMedicine:(NSSet *)values;
- (void)removeRecipeMedicine:(NSSet *)values;

@end
