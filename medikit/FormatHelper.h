//
//  FormatHelper.h
//  Medikit
//
//  Created by Alonso Vega on 8/21/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Recipe;

@interface FormatHelper : NSObject

+ (NSString *)stringForRecipeDate:(NSDate *)date;
+ (NSString *)stringForRecipeInterval:(NSNumber *)interval;
+ (NSString *)stringForRecipeDosis:(Recipe *)recipe;
+ (NSString *)stringForRecipeDuration:(Recipe *)recipe;
+ (NSString *)stringForRecipeDosisPerDay:(Recipe *)recipe;
+ (NSString *)stringForRecipeSingleDosisPerDay:(Recipe *)recipe;

@end
