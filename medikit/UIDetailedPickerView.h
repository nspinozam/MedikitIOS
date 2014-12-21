//
//  UIDetailedPickerView.h
//  Medikit
//
//  Created by Alonso Vega on 8/16/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIPickerViewForDosis,
    UIPickerViewForDuration
} UIPickerViewForField;

@interface UIDetailedPickerView : UIPickerView

@property (nonatomic, readwrite, assign) UIPickerViewForField field;

@end
