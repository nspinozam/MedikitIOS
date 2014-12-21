//
//  FormatHelper.m
//  Medikit
//
//  Created by Alonso Vega on 8/21/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import "FormatHelper.h"
#import "Recipe.h"

@implementation FormatHelper

NSInteger const HourMinutes = 60;

+ (NSString *)stringForRecipeDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    return [formatter stringFromDate:date];
}

+ (NSString *)stringForRecipeInterval:(NSNumber *)interval
{
    NSInteger hours = [interval integerValue] / HourMinutes,
        minutes = [interval integerValue] % HourMinutes;
    return [NSString stringWithFormat:@"%dh %02dm",
            hours, minutes];
}

+ (NSString *)stringForRecipeDuration:(Recipe *)recipe
{
    return [NSString stringWithFormat:@"%@ %@",
            recipe.duration,
            recipe.durationType];
}

+ (NSString *)stringForRecipeDosis:(Recipe *)recipe
{
    return [NSString stringWithFormat:@"%@ %@",
            recipe.dosisAmount,
            recipe.dosisType];
}

+ (NSString *)stringForRecipeDosisPerDay:(Recipe *)recipe
{
    return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Times", @"texts", nil),
            recipe.dosisPerDay];
}

+ (NSString *)stringForRecipeSingleDosisPerDay:(Recipe *)recipe
{
    return [NSString stringWithFormat:@"%@", recipe.dosisPerDay];
}

@end
