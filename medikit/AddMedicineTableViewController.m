//
//  AddMedicineTableViewController.m
//  medikit
//
//  Created by Nixon Espinoza on 12/22/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import "AddMedicineTableViewController.h"
#import "Medicine.h"
#import "SOTextField.h"

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.medicineGenericName.field = FieldForGenericName;
    self.medicineCommercialName.field = FieldForCommercialName;
    
    self.dataEntered = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveRecipeAndReturnToView:)];
    [self setSaveButtonEnabled:NO];
    [self setFieldsEditable:YES];
    // Create a temporal object for storing the new recipe until it's saved
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    _tempMedicine = [[Medicine alloc] initWithEntity:entity
                    insertIntoManagedObjectContext:nil];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveRecipeAndReturnToView:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Medicine *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                              inManagedObjectContext:context];
    
    _savedMedicine = newManagedObject;
    
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
    if ([textField isKindOfClass:[SOTextField class]])
    {
        SOTextField *detailedField = (SOTextField *)textField;
        switch (detailedField.field) {
            case FieldForCommercialName:
                _tempMedicine.comercialName = textField.text;
                break;
            case FieldForGenericName:
            {
                _tempMedicine.genericName = textField.text;
            }
            default:
                break;
        }
        [self checkSaveButtonShouldAppear];
    }
}

#pragma mark - Table view data source


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

- (void)checkSaveButtonShouldAppear
{
    self.dataEntered = YES;
    if (_tempMedicine)
    {
        if (_tempMedicine.genericName &&
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


@end
