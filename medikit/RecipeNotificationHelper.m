//
//  RecipeNotificationHelper.m
//  Medikit
//
//  Created by Alonso Vega on 8/19/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import "RecipeNotificationHelper.h"
#import "Recipe.h"

@implementation RecipeNotificationHelper

NSInteger const SecondsInMinute = 60;
NSInteger const SecondsInDay = 24.0 * 60.0 * 60.0;

+ (void)setLocalNotificationForRecipe:(Recipe *)recipe
{
    [self setLocalNotificationForRecipe:recipe atTime:[self nextDosisForRecipe:recipe]];
}

+ (void)setLocalNotificationForRecipe:(Recipe *)recipe atTime:(NSDate *)fireDate
{
    if (!fireDate) return;
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSString *recipeId = [[recipe.objectID URIRepresentation] absoluteString];
    [info setValue:recipeId forKey:@"Recipe"];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"Medicamento pendiente: %@ para alguien", recipe.name];
    //notification.alertBody = [NSString stringWithFormat:NSLocalizedStringFromTable(@"NotificationAlertBody", @"texts", nil), recipe.name];//, recipe.patient
    notification.alertAction = @"Ver";
    notification.fireDate = fireDate;
    notification.userInfo = info;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    NSLog(@"Set %@ to %@", recipe.name, [self printDate:notification.fireDate]);
}

+ (BOOL)isDate:(NSDate *)date duringTimeForRecipe:(Recipe *)recipe
{
    NSInteger daysForRecipe = [recipe.durationTotal integerValue];
    NSDate *endingDate = [recipe.dosisStartTime dateByAddingTimeInterval:(daysForRecipe *SecondsInDay)];
    if ([date compare:endingDate] == NSOrderedAscending) {
        NSLog(@"Entra");
        return true;
    }else{
        NSLog(@"NO entra");
        return false;
    }
    //return ([date compare:endingDate] == NSOrderedDescending);
}

+ (NSDate *)nextDosisForRecipe:(Recipe *)recipe
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    // Get recipe important components (Hour and Minutes)
    NSDateComponents *componentsForRecipeDate = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:recipe.dosisStartTime];
    // Get current components of year, month and day
    NSDateComponents *componentsForNow = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    
    // Set remaining components of recipe to current
    componentsForRecipeDate.year = componentsForNow.year;
    componentsForRecipeDate.month = componentsForNow.month;
    componentsForRecipeDate.day = componentsForNow.day;
    // And set seconds to 0
    componentsForRecipeDate.second = 0;
    
    // The next dosis is the union of current and recipe components
    NSDate *nextDosis = [calendar dateFromComponents:componentsForRecipeDate];
     
    // Interval to add when checking next dosis date
    NSTimeInterval secondsAdded = [recipe.dosisInterval integerValue] * SecondsInMinute;
    
    // Check by dosis per day the next dosis date
    for (int i = 0; i < [recipe.dosisPerDay intValue]; i++) {
        // If next dosis passed, check next one
        if ([now compare:nextDosis] == NSOrderedAscending)
        {
            if ([self isDate:nextDosis duringTimeForRecipe:recipe])
            {
                return nextDosis;
            } else {
                return nil;
            }
        } else {
            nextDosis = [nextDosis dateByAddingTimeInterval:secondsAdded];
        }
    }
    return nextDosis;
}

// Debug method to check local format datetime
+ (NSString *)printDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"America/Costa_Rica"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:timeZone];
    return [formatter stringFromDate:date];
}

@end