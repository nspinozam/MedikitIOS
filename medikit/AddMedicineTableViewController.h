//
//  AddMedicineTableViewController.h
//  medikit
//
//  Created by Nixon Espinoza on 12/22/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Medicine;
@class Recipe;
@class MedicineTextField;

@interface AddMedicineTableViewController : UITableViewController<UISplitViewControllerDelegate,
                                                                    UITextFieldDelegate>

@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Medicine *savedMedicine;
@property (strong, nonatomic) UITextField *currentField;

//section
@property (weak, nonatomic) IBOutlet MedicineTextField *medicineGenericName;
@property (weak, nonatomic) IBOutlet MedicineTextField *medicineCommercialName;
@property (strong, nonatomic) Recipe *recipe;

@end
