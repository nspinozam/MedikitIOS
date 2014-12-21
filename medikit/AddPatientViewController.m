//
//  AddPatientViewController.m
//  medikit
//
//  Created by Estudiante on 26/08/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import "AddPatientViewController.h"
#import "Patient.h"
#import "SOTextField.h"

@interface AddPatientViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
// If any data has been entered into the form
@property (nonatomic) BOOL dataEntered;
// Temporal recipe object to store input data before Save button is pressed
@property (strong, nonatomic) Patient *tempPatient;

@end

@implementation AddPatientViewController
// Constants definition
NSString * const EmptyNSStringP = @"";

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
    self.patientNameField.field = FieldForPatientName;
    
    self.dataEntered = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveRecipeAndReturnToView:)];
    [self setSaveButtonEnabled:NO];
    [self setFieldsEditable:YES];
    // Create a temporal object for storing the new recipe until it's saved
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    _tempPatient = [[Patient alloc] initWithEntity:entity
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
    Patient *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                             inManagedObjectContext:context];
    
    _savedPatient = newManagedObject;
    
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
    
    self.savedPatient.name = _tempPatient.name;
    
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
        _tempPatient.name = textField.text;
        [self checkSaveButtonShouldAppear];
    }
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

- (void)checkSaveButtonShouldAppear
{
    self.dataEntered = YES;
    if (_tempPatient)
    {
        if (_tempPatient.name &&
            ![_tempPatient.name isEqualToString:EmptyNSStringP])
        {
            [self setSaveButtonEnabled:YES];
        } else {
            [self setSaveButtonEnabled:NO];
        }
    }
}

- (void)setFieldsEditable:(BOOL)editable
{
    self.patientNameField.enabled = editable;
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
