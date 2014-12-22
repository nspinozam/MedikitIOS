//
//  DetailViewController.h
//  Medikit
//
//  Created by Alonso Vega on 8/14/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Recipe;
@class SOTextField;
@class Patient;

typedef enum {
    ShowStateNew = 1,
    ShowStateView = 2,
    ShowStateEdit = 3
} ShowState;

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate,
                                                            UITextFieldDelegate,
                                                            UIPickerViewDataSource,
                                                            UIPickerViewDelegate>

@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Recipe *savedRecipe;
@property (strong, nonatomic) UITextField *currentField;
@property (nonatomic) ShowState showState;

// Med section
@property (weak, nonatomic) IBOutlet SOTextField *recipeNameField;
@property (weak, nonatomic) IBOutlet SOTextField *recipeStartDateField;
@property (weak, nonatomic) IBOutlet SOTextField *recipeDailyPortionsField;
@property (weak, nonatomic) IBOutlet SOTextField *recipeIntervalField;
@property (weak, nonatomic) IBOutlet SOTextField *recipePortionDosisField;
@property (weak, nonatomic) IBOutlet SOTextField *recipeDurationField;
@property (strong, nonatomic) Patient *patient;


@end
