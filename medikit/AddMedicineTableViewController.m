//
//  AddMedicineTableViewController.m
//  medikit
//
//  Created by Nixon Espinoza on 12/22/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import "AddMedicineTableViewController.h"
#import "Medicine.h"
#import "MedicineTextField.h"

@interface AddMedicineTableViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
// If any data has been entered into the form
@property (nonatomic) BOOL dataEntered;
// Temporal recipe object to store input data before Save button is pressed
@property (strong, nonatomic) Medicine *tempMedicine;

@end

@implementation AddMedicineTableViewController

// Constants definition
NSString * const EmptyNSStringM = @"";
NSInteger const TagForFieldInCellM = 1;


#pragma mark - Managing the detail item
//Temp
- (void)setSavedMedicine:(id)newSavedRecipe
{
    if (_savedMedicine != newSavedRecipe) {
        _savedMedicine = newSavedRecipe;
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.medicineGenericName.field = FieldForGenericName;
    self.medicineCommercialName.field = FieldForComercialName;
    self.recipe = nil;
    
    self.dataEntered = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveRecipeAndReturnToView:)];
    [self setSaveButtonEnabled:NO];
    [self setFieldsEditable:YES];
    // Create a temporal object for storing the new recipe until it's saved
    Medicine *result = (Medicine *)[NSEntityDescription insertNewObjectForEntityForName:@"Medicine" inManagedObjectContext:_managedObjectContext];
    _tempMedicine=result;

}


- (IBAction)saveRecipeAndReturnToView:(id)sender
{
    _savedMedicine = _tempMedicine;
    
    [self saveChangesAndReturnToView:sender];
}


- (void)setSaveButtonEnabled:(BOOL)enabled
{
    if (self.navigationItem.rightBarButtonItem)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:enabled];
    }
}


- (IBAction)saveChangesAndReturnToView:(id)sender
{
    [self.view.window endEditing:YES];
    
    self.savedMedicine.genericName = _tempMedicine.genericName;
    self.savedMedicine.comercialName = _tempMedicine.comercialName;
    
    // Save the context.
    NSError *error = nil;
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isKindOfClass:[MedicineTextField class]])
    {
        MedicineTextField *detailedField = (MedicineTextField *)textField;

        switch (detailedField.field) {
            case FieldForComercialName:
                _tempMedicine.comercialName = textField.text;
                 NSLog(@"Seteo el comercial con: %@",textField.text);
                break;
            case FieldForGenericName:
            {
                _tempMedicine.genericName = textField.text;
                NSLog(@"Seteo el generic con: %@",textField.text);
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
#pragma mark - Field navigation methods

- (IBAction)FieldNavigationPrev:(id)sender {
    if (self.currentField)
    {
        [self.currentField resignFirstResponder];
        UITextField *prevField = [(MedicineTextField *)self.currentField prevField];
        [prevField becomeFirstResponder];
        self.currentField = prevField;
    }
}

- (IBAction)FieldNavigationNext:(id)sender {
    if (self.currentField)
    {
        [self.currentField resignFirstResponder];
        UITextField *nextField = [(MedicineTextField *)self.currentField nextField];
        [nextField becomeFirstResponder];
        self.currentField = nextField;
    }
}

- (IBAction)FieldNavigationDone:(id)sender
{
    [self.currentField resignFirstResponder];
}

#pragma mark - Table view data source


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    if ([textField isKindOfClass:[MedicineTextField class]])
    {
        if (textField.returnKeyType == UIReturnKeyNext)
            [[(MedicineTextField *)textField nextField] becomeFirstResponder];
    }
    
    return YES;
}

- (void)checkSaveButtonShouldAppear
{
    self.dataEntered = YES;
    if (_tempMedicine)
    {
        if (_tempMedicine.genericName &&
            ![_tempMedicine.genericName isEqualToString:EmptyNSStringM] &&
            _tempMedicine.comercialName &&
            ![_tempMedicine.comercialName isEqualToString:EmptyNSStringM])
        {
            [self setSaveButtonEnabled:YES];
        } else {
            [self setSaveButtonEnabled:NO];
        }
    }
}

- (void)setFieldsEditable:(BOOL)editable
{
    self.medicineCommercialName.enabled = editable;
    self.medicineGenericName.enabled = editable;
}

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

#pragma mark - Table View events
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField *field = (UITextField *)[selectedCell viewWithTag:TagForFieldInCellM];
    [field becomeFirstResponder];
}


@end
