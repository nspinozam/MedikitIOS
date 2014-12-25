//
//  SOTextField.h
//  Medikit
//
//  Created by Alonso Vega on 8/16/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FieldForRecipeName = 1,
    FieldForRecipeDate,
    FieldForDosisPerDay,
    FieldForInterval,
    FieldForPortionDosis,
    FieldForDuration,
    FieldForPatientName,
    FieldForGenericName,
    FieldForCommercialName
} FieldForComponent;

@interface SOTextField : UITextField

@property (nonatomic, readwrite, assign) FieldForComponent field;
@property (nonatomic, readwrite, assign) IBOutlet UITextField *nextField;
@property (nonatomic, readwrite, assign) IBOutlet UITextField *prevField;

@end
