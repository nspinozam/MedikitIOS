//
//  DetailViewController.m
//  Medikit
//
//  Created by Alonso Vega on 8/14/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import "DetailViewController.h"
#import "Recipe.h"
#import "SOTextField.h"
#import "UIDetailedPickerView.h"
#import "RecipeNotificationHelper.h"
#import "FormatHelper.h"
#import "Patient.h"
#import "RecipeListNameTableViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

// Fixed values arrays
@property (strong, nonatomic) NSArray *quantityTypes;
@property (strong, nonatomic) NSArray *quantities;
@property (strong, nonatomic) NSArray *durationTypes;
@property (strong, nonatomic) NSArray *durationValues;

// Temporal recipe object to store input data before Save button is pressed
@property (strong, nonatomic) Recipe *tempRecipe;

// If any data has been entered into the form
@property (nonatomic) BOOL dataEntered;

- (void)showDataForRecipe:(Recipe *)recipe;
@end

@implementation DetailViewController

// Constants definition
NSString * const EmptyNSString = @"";

NSString * const RecipeDataQuantityTypesKey = @"QuantityTypes";
NSString * const RecipeDataQuantitesKey = @"Quantities";
NSString * const RecipeDataDurationTypesKey = @"DurationTypes";
NSString * const RecipeDataDurationValuesKey = @"DurationValues";

NSString * const KeyForQuantityName = @"name";
NSString * const KeyForQuantityValue = @"value";

NSInteger const DurationIndexValueOffset = 1;
NSInteger const QuantitiesIndexValueOffset = -1;
NSInteger const QuantitiesMaximumOffset = 15;

NSInteger const TagForFieldInCell = 1;

NSInteger const SectionsForDosisPicker = 2;
NSInteger const SectionsForDurationPicker = 2;

NSInteger const DosisAmountQuantitySectionIndex = 0;
NSInteger const DosisAmountQuantityTypeSectionIndex = 1;
NSInteger const DurationQuantitySectionIndex = 0;
NSInteger const DurationTypeSectionIndex = 1;

NSInteger const DurationQuantityMaximun = 50;

NSInteger const EightHoursInMinutes = 480;
NSInteger const MinutesInHour = 60;

NSInteger const RowsForUnknownPickerViewSection;
NSString * const TitleForUnknownPickerViewRow = @"";

// Synthesize properties
@synthesize showState;
@synthesize fetchedResultsController;

#pragma mark - Managing the detail item

- (void)setSavedRecipe:(id)newSavedRecipe
{
    if (_savedRecipe != newSavedRecipe) {
        _savedRecipe = newSavedRecipe;
        
        // Update the view.
        [self showDataForRecipe:self.savedRecipe];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)showDataForRecipe:(Recipe *)recipe;
{
    // Update the user interface for the detail item.
    
    // Recipe name
    self.recipeNameField.text = recipe.name;
    
    // Dosis start date
    self.recipeStartDateField.text = [FormatHelper stringForRecipeDate:recipe.dosisStartTime];
    
    // Daily dosis
    self.recipeDailyPortionsField.text = [FormatHelper stringForRecipeDosisPerDay:recipe];
    
    // Show interval
    self.recipeIntervalField.text = [FormatHelper stringForRecipeInterval:recipe.dosisInterval];
    
    // Show dosis
    self.recipePortionDosisField.text = [FormatHelper stringForRecipeDosis:recipe];
    
    // Show duration
    self.recipeDurationField.text = [FormatHelper stringForRecipeDuration:recipe];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load unit names from plist file
    NSString *recipeDataFilename = [[NSBundle mainBundle] pathForResource:@"RecipeData"
                                                                   ofType:@"plist"];
    NSDictionary *recipeData = [[NSDictionary alloc] initWithContentsOfFile:recipeDataFilename];
    self.quantityTypes = (NSArray *)[recipeData objectForKey:RecipeDataQuantityTypesKey];
    self.quantities = (NSArray *)[recipeData objectForKey:RecipeDataQuantitesKey];
    self.durationTypes = (NSArray *)[recipeData objectForKey:RecipeDataDurationTypesKey];
    self.durationValues = (NSArray *)[recipeData objectForKey:RecipeDataDurationValuesKey];
    
	// Switch to given state (view, edit, new)
    [self switchShowState:self.showState];

    self.recipeNameField.field = FieldForRecipeName;
    self.recipeStartDateField.field = FieldForRecipeDate;
    self.recipeDailyPortionsField.field = FieldForDosisPerDay;
    self.recipeIntervalField.field = FieldForInterval;
    self.recipePortionDosisField.field = FieldForPortionDosis;
    self.recipeDurationField.field = FieldForDuration;
    
    // Give custom input views
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    datePicker.datePickerMode = UIDatePickerModeTime;
    [datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    self.recipeStartDateField.inputView = datePicker;
    self.recipeStartDateField.placeholder = [FormatHelper stringForRecipeDate:[NSDate date]];
    
    UIDatePicker *intervalPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    intervalPicker.datePickerMode = UIDatePickerModeCountDownTimer;
    [intervalPicker addTarget:self action:@selector(intervalPickerChanged:) forControlEvents:UIControlEventValueChanged];
    self.recipeIntervalField.inputView = intervalPicker;

    UIDetailedPickerView *pickerForDosis = [[UIDetailedPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    pickerForDosis.showsSelectionIndicator = YES;
    pickerForDosis.field = UIPickerViewForDosis;
    pickerForDosis.delegate = self;
    self.recipePortionDosisField.inputView = pickerForDosis;
    
    UIDetailedPickerView *pickerForDuration = [[UIDetailedPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    pickerForDuration.showsSelectionIndicator = YES;
    pickerForDuration.field = UIPickerViewForDuration;
    pickerForDuration.delegate = self;
    self.recipeDurationField.inputView = pickerForDuration;
    
    self.dataEntered = NO;

}

- (void)switchShowState:(ShowState)newState
{
    switch (newState) {
        case ShowStateNew:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                   target:self
                                                                                                   action:@selector(saveRecipeAndReturnToView:)];
            [self setSaveButtonEnabled:NO];
            [self setFieldsEditable:YES];
            // Create a temporal object for storing the new recipe until it's saved
            NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
            _tempRecipe = [[Recipe alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:nil];
            break;
        }
        case ShowStateView:
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                                   target:self
                                                                                                   action:@selector(enterEditMode:)];
            [self showDataForRecipe:self.savedRecipe];
            [self setFieldsEditable:NO];
            _tempRecipe = _savedRecipe;
            break;
        case ShowStateEdit:
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                   target:self
                                                                                                   action:@selector(saveChangesAndReturnToView:)];
            [self setFieldsEditable:YES];
            break;
        default:
            break;
    }
}

- (IBAction)enterEditMode:(id)sender
{
    [self switchShowState:ShowStateEdit];
}

- (IBAction)saveChangesAndReturnToView:(id)sender
{
    [self.view.window endEditing:YES];
    
    self.savedRecipe.name = _tempRecipe.name;
    self.savedRecipe.dosisStartTime = _tempRecipe.dosisStartTime;
    self.savedRecipe.dosisPerDay = _tempRecipe.dosisPerDay;
    self.savedRecipe.dosisInterval = _tempRecipe.dosisInterval;
    self.savedRecipe.dosisAmount = _tempRecipe.dosisAmount;
    self.savedRecipe.dosisType = _tempRecipe.dosisType;
    self.savedRecipe.duration = _tempRecipe.duration;
    self.savedRecipe.durationType = _tempRecipe.durationType;
    self.savedRecipe.durationTotal = _tempRecipe.durationTotal;
    self.savedRecipe.patientParent = self.patient;
    
    // Save the context.
    NSError *error = nil;
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Create a notification
    [RecipeNotificationHelper setLocalNotificationForRecipe:self.savedRecipe];
    
    [self switchShowState:ShowStateView];
}

- (IBAction)saveRecipeAndReturnToView:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Recipe *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                    inManagedObjectContext:context];
    
    _savedRecipe = newManagedObject;
    
    [self saveChangesAndReturnToView:sender];
}

- (void)setFieldsEditable:(BOOL)editable
{
    self.recipeNameField.enabled = editable;
    self.recipeStartDateField.enabled = editable;
    self.recipeDailyPortionsField.enabled = editable;
    self.recipeIntervalField.enabled = editable;
    self.recipePortionDosisField.enabled = editable;
    self.recipeDurationField.enabled = editable;
}

- (void)setSaveButtonEnabled:(BOOL)enabled
{
    if (self.navigationItem.rightBarButtonItem)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:enabled];
    }
}

- (void)checkSaveButtonShouldAppear
{
    self.dataEntered = YES;
    if (_tempRecipe)
    {
        if (_tempRecipe.name &&
            ![_tempRecipe.name isEqualToString:EmptyNSString] &&
            _tempRecipe.dosisStartTime &&
            ([_tempRecipe.dosisPerDay intValue] > 0) &&
            ([_tempRecipe.dosisInterval intValue] > 0) &&
            ([_tempRecipe.dosisAmount doubleValue] > 0) &&
            ![_tempRecipe.dosisType isEqualToString:EmptyNSString] &&
            ([_tempRecipe.duration intValue] > 0) &&
            ![_tempRecipe.durationType isEqualToString:EmptyNSString])
        {
            [self setSaveButtonEnabled:YES];
        } else {
            [self setSaveButtonEnabled:NO];
        }
    }
}

#pragma mark - Field navigation methods

- (IBAction)FieldNavigationPrev:(id)sender {
    if (self.currentField)
    {
        [self.currentField resignFirstResponder];
        UITextField *prevField = [(SOTextField *)self.currentField prevField];
        [prevField becomeFirstResponder];
        self.currentField = prevField;
    }
}

- (IBAction)FieldNavigationNext:(id)sender {
    if (self.currentField)
    {
        [self.currentField resignFirstResponder];
        UITextField *nextField = [(SOTextField *)self.currentField nextField];
        [nextField becomeFirstResponder];
        self.currentField = nextField;
    }
}

- (IBAction)FieldNavigationDone:(id)sender
{
    [self.currentField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //code.tutsplus.com/tutorials/core-data-from-scratch-relationships-and-more-fetching--cms-21505
    NSString *segueIdentifier = [segue identifier];
    id destinationController = [segue destinationViewController];
    
    if ([segueIdentifier isEqualToString:@"toMedicineList"])
    {
        /*RecipeListNameTableViewController* rLNTVC = [segue destinationViewController];
        rLNTVC.toMed = self.fetchedResultsController;*/
        //[destinationController setFetchedResultsController:self.fetchedResultsController];
        [destinationController setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Text Field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    if ([textField isKindOfClass:[SOTextField class]])
    {
        if (textField.returnKeyType == UIReturnKeyNext)
            [[(SOTextField *)textField nextField] becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentField = textField;
    if ([textField isKindOfClass:[SOTextField class]])
    {
        SOTextField *field = (SOTextField *)textField;
        switch (field.field) {
            case FieldForRecipeDate:
                if (!_tempRecipe.dosisStartTime)
                {
                    _tempRecipe.dosisStartTime = [NSDate date];
                    textField.text = [FormatHelper stringForRecipeDate:_tempRecipe.dosisStartTime];
                }
                break;
                
            case FieldForDosisPerDay:
                textField.text = [FormatHelper stringForRecipeSingleDosisPerDay:_tempRecipe];
                break;
                
            case FieldForInterval:
                if ([_tempRecipe.dosisInterval intValue] == 0)
                {
                    _tempRecipe.dosisInterval = [NSNumber numberWithInt:EightHoursInMinutes];
                    
                    UIDatePicker *intervalPicker = (UIDatePicker *)textField.inputView;
                    [intervalPicker setCountDownDuration:EightHoursInMinutes * 60];
                    
                    textField.text = [FormatHelper stringForRecipeInterval:_tempRecipe.dosisInterval];
                }
                break;
                
            case FieldForPortionDosis:
            {
                if (![_tempRecipe.dosisAmount intValue] > 0)
                {
                    _tempRecipe.dosisAmount = [NSNumber numberWithInt:1];
                }
                if (!_tempRecipe.dosisType)
                {
                    _tempRecipe.dosisType = [self.quantityTypes objectAtIndex:0];
                }
                UIPickerView *dosisPicker = (UIPickerView *)textField.inputView;
                [dosisPicker selectRow:2 inComponent:DosisAmountQuantitySectionIndex animated:YES];
                [dosisPicker selectRow:0 inComponent:DosisAmountQuantityTypeSectionIndex animated:YES];
                
                textField.text = [FormatHelper stringForRecipeDosis:_tempRecipe];
                break;
            }
                
            case FieldForDuration:
            {
                if ([_tempRecipe.duration intValue] == 0)
                {
                    _tempRecipe.duration = [NSNumber numberWithInt:1];
                }
                if (!_tempRecipe.durationType)
                {
                    _tempRecipe.durationType = [self.durationTypes objectAtIndex:1];
                }
                
                _tempRecipe.durationTotal = [NSNumber numberWithInt:[_tempRecipe.duration intValue] *
                                             [[self.durationValues objectAtIndex:1] intValue]];
                
                UIPickerView *durationPicker = (UIPickerView *)textField.inputView;
                [durationPicker selectRow:0 inComponent:DosisAmountQuantitySectionIndex animated:YES];
                [durationPicker selectRow:1 inComponent:DosisAmountQuantityTypeSectionIndex animated:YES];
                
                textField.text = [FormatHelper stringForRecipeDuration:_tempRecipe];
                break;
            }

            default:
                break;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isKindOfClass:[SOTextField class]])
    {
        SOTextField *detailedField = (SOTextField *)textField;
        switch (detailedField.field) {
            case FieldForRecipeName:
                _tempRecipe.name = textField.text;
                break;
            case FieldForDosisPerDay:
            {
                NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                _tempRecipe.dosisPerDay = [numberFormatter numberFromString:textField.text];
                if ([_tempRecipe.dosisPerDay integerValue] == 0) _tempRecipe.dosisPerDay = [NSNumber numberWithInteger:1];
                detailedField.text = [FormatHelper stringForRecipeDosisPerDay:_tempRecipe];
                _tempRecipe.dosisInterval = [NSNumber numberWithInteger:((24 * 60) /
                                                                         [_tempRecipe.dosisPerDay intValue])];
                self.recipeIntervalField.text = [FormatHelper stringForRecipeInterval:_tempRecipe.dosisInterval];
                break;
            }
            case FieldForInterval:
            {
                if ([_tempRecipe.dosisInterval integerValue] > 0)
                {
                    _tempRecipe.dosisPerDay = [NSNumber numberWithInteger:((24 * 60) /
                                                                           [_tempRecipe.dosisInterval intValue])];
                    self.recipeDailyPortionsField.text = [FormatHelper stringForRecipeDosisPerDay:_tempRecipe];
                }
                break;
            }
            default:
                break;
        }
        [self checkSaveButtonShouldAppear];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIToolbar *fieldNavigation = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"PrevButton", @"texts", nil) // @"Anterior"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(FieldNavigationPrev:)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"NextButton", @"texts", nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(FieldNavigationNext:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"DoneButton", @"texts", nil)
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(FieldNavigationDone:)];
    
    fieldNavigation.items = [NSArray arrayWithObjects:flexibleSpace, prevButton, nextButton, flexibleSpace, doneButton, nil];
    textField.inputAccessoryView = fieldNavigation;
    return YES;
}

#pragma mark - Table View events
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField *field = (UITextField *)[selectedCell viewWithTag:TagForFieldInCell];
    [field becomeFirstResponder];
}

#pragma mark - Picker View Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    UIDetailedPickerView *detailedPicker = (UIDetailedPickerView *)pickerView;
    switch (detailedPicker.field) {
        case UIPickerViewForDosis:
            return SectionsForDosisPicker;
        case UIPickerViewForDuration:
            return SectionsForDurationPicker;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    UIDetailedPickerView *detailedPicker = (UIDetailedPickerView *)pickerView;
    switch (detailedPicker.field) {
        case UIPickerViewForDosis:
            if (component == DosisAmountQuantitySectionIndex)
                return [self.quantities count] + QuantitiesMaximumOffset;
            else if (component == DosisAmountQuantityTypeSectionIndex)
                return [self.quantityTypes count];
        case UIPickerViewForDuration:
            if (component == DurationQuantitySectionIndex)
                return DurationQuantityMaximun;
            else if (component == DurationTypeSectionIndex)
                return [self.durationTypes count];
    }
    return RowsForUnknownPickerViewSection;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    UIDetailedPickerView *detailedPicker = (UIDetailedPickerView *)pickerView;
    switch (detailedPicker.field) {
        case UIPickerViewForDosis:
            if (component == DosisAmountQuantitySectionIndex)
            {
                if (row < [self.quantities count])
                    return [[self.quantities objectAtIndex:row] objectForKey:KeyForQuantityName];
                else
                    return [NSString stringWithFormat:@"%d", row + QuantitiesIndexValueOffset];
            }
            else if (component == DosisAmountQuantityTypeSectionIndex)
            {
                return [self.quantityTypes objectAtIndex:row];
            }
        case UIPickerViewForDuration:
            if (component == DurationQuantitySectionIndex)
                return [NSString stringWithFormat:@"%d", row + DurationIndexValueOffset];
            else if (component == DurationTypeSectionIndex)
                return [self.durationTypes objectAtIndex:row];
    }
    return TitleForUnknownPickerViewRow;
}

#pragma mark - Picker View Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    UIDetailedPickerView *detailedPicker = (UIDetailedPickerView *)pickerView;
    switch (detailedPicker.field) {
        case UIPickerViewForDosis:
            if (component == DosisAmountQuantitySectionIndex)
            {
                if (row < [self.quantities count])
                {
                    NSNumber *dosisAmount = [[self.quantities objectAtIndex:row] objectForKey:KeyForQuantityValue];
                    _tempRecipe.dosisAmount = dosisAmount;
                }
                else
                {
                    _tempRecipe.dosisAmount = [NSNumber numberWithInteger:row + QuantitiesIndexValueOffset];
                }
            }
            else if (component == DosisAmountQuantityTypeSectionIndex)
            {
                _tempRecipe.dosisType = [self.quantityTypes objectAtIndex:row];
            }
            
            // Show dosis
            self.recipePortionDosisField.text = [FormatHelper stringForRecipeDosis:_tempRecipe];
            break;
        case UIPickerViewForDuration:
            if (component == DurationQuantitySectionIndex)
                _tempRecipe.duration = [NSNumber numberWithInteger:row + DurationIndexValueOffset];
            else if (component == DurationTypeSectionIndex)
                _tempRecipe.durationType = [self.durationTypes objectAtIndex:row];

            _tempRecipe.durationTotal = [NSNumber numberWithInt:([_tempRecipe.duration intValue] *
                                                                 [[self.durationValues objectAtIndex:row] intValue])];
            // Show duration
            self.recipeDurationField.text = [FormatHelper stringForRecipeDuration:_tempRecipe];
            break;
    }
    [self checkSaveButtonShouldAppear];
}

- (IBAction)datePickerChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    _tempRecipe.dosisStartTime = datePicker.date;
    self.recipeStartDateField.text = [FormatHelper stringForRecipeDate:_tempRecipe.dosisStartTime];
    
    [self checkSaveButtonShouldAppear];
}

- (IBAction)intervalPickerChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:[datePicker date]];
    NSInteger totalMinutes = ([components hour] * 60) + [components minute];
    _tempRecipe.dosisInterval = [NSNumber numberWithInteger:totalMinutes];
    
    self.recipeIntervalField.text = [FormatHelper stringForRecipeInterval:_tempRecipe.dosisInterval];
    
    [self checkSaveButtonShouldAppear];

}

@end
