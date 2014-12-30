//
//  RecipeListNameTableViewController.h
//  medikit
//
//  Created by Nixon Espinoza on 12/21/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Medicine;
@class AddMedicineTableViewController;

#import <CoreData/CoreData.h>


@protocol RecipeListNameTableViewControllerDelegate <NSObject>
- (void)returnedMedicine:(Medicine *)med;
@end

@interface RecipeListNameTableViewController : UITableViewController
{
}

@property (assign) id <RecipeListNameTableViewControllerDelegate> delegate;

@property (strong, nonatomic) Medicine *savedMedicine;

@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSFetchedResultsController *toMed;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
