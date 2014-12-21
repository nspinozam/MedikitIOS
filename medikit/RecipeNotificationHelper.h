//
//  RecipeNotificationHelper.h
//  Medikit
//
//  Created by Alonso Vega on 8/19/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Recipe;
@class Patient;

@interface RecipeNotificationHelper : NSObject

+ (void)setLocalNotificationForRecipe:(Recipe *)recipe;
+ (void)setLocalNotificationForRecipe:(Recipe *)recipe atTime:(NSDate *)fireDate;

@end
