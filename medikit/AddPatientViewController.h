//
//  AddPatientViewController.h
//  medikit
//
//  Created by Estudiante on 26/08/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Patient;
@class SOTextField;

@interface AddPatientViewController : UITableViewController <UISplitViewControllerDelegate,
                                                                UITextFieldDelegate>

@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Patient *savedPatient;
@property (strong, nonatomic) UITextField *currentField;

//section
@property (weak, nonatomic) IBOutlet SOTextField *patientNameField;

@end
