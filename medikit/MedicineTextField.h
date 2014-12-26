//
//  MedicineTextField.h
//  medikit
//
//  Created by Nixon Espinoza on 12/25/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FieldForComercialName = 0,
    FieldForGenericName=1
} FieldForComponent;

@interface MedicineTextField : UITextField

@property (nonatomic, readwrite, assign) FieldForComponent field;
@property (nonatomic, readwrite, assign) IBOutlet UITextField *nextField;
@property (nonatomic, readwrite, assign) IBOutlet UITextField *prevField;

@end
