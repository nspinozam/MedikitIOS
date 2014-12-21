//
//  MasterViewController.h
//  Medikit
//
//  Created by Alonso Vega on 8/14/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class TableViewController;
@class Patient;

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController 

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) TableViewController *tableViewController;
@property (strong, nonatomic) Patient *savedPatient;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
