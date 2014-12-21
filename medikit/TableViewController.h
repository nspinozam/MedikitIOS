//
//  TableViewController.h
//  medikit
//
//  Created by Estudiante on 20/08/14.
//  Copyright (c) 2014 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Patient;
@class DetailViewController;


#import <CoreData/CoreData.h>

@interface TableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) Patient *patient;

@end