//
//  RecipeListNameTableViewController.h
//  medikit
//
//  Created by Nixon Espinoza on 12/21/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Medicine;

#import <CoreData/CoreData.h>

@interface RecipeListNameTableViewController : UITableViewController

@property (strong, nonatomic) Medicine *savedMedicine;

@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
