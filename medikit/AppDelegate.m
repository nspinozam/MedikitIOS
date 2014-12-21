//
//  AppDelegate.m
//  Medikit
//
//  Created by Alonso Vega on 8/14/13.
//  Copyright (c) 2013 tec. All rights reserved.
//

#import "AppDelegate.h"
#import "Recipe.h"
#import "RecipeNotificationHelper.h"

#import "MasterViewController.h"
#import "TableViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize recipeForAlert;

NSString * const AlertTitleKey = @"AlertTitle";
NSString * const AlertBodyKey = @"AlertBody";
NSString * const AlertOkKey = @"AlertOk";
NSString * const AlertSnoozeKey = @"AlertSnooze";
NSString * const StringTable = @"texts";

NSInteger const DoneButtonIndex = 0;
NSInteger const SnoozeButtonIndex = 1;

NSInteger const TenMinutes = 60 * 10;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    
    // Check if app started with new notification
    UILocalNotification *localNotif =
        [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif)
    {
        [self application:application didReceiveLocalNotification:localNotif];
    }
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Get recipe for notification
    Recipe *recipe = [self recipeForLocalNotification:notification];
    self.recipeForAlert = recipe;
    // Show an alert for recipe
    [self showAlertForRecipe:recipe];
}

- (Recipe *)recipeForLocalNotification:(UILocalNotification *)notification
{
    // Check which recipe made the notification by looking in the user info object
    NSString *recipeUri = [notification.userInfo objectForKey:@"Recipe"];
    NSManagedObjectID *objectId = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:recipeUri]];
    return (Recipe *)[self.managedObjectContext objectRegisteredForID:objectId];
}

- (void)showAlertForRecipe:(Recipe *)recipe
{
    if (!recipe) return;
    // Show an alert with the recipe info
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(AlertTitleKey, StringTable, nil)
                                                    message:[NSString stringWithFormat:NSLocalizedStringFromTable(AlertBodyKey, StringTable, nil),
                                                             recipe.name,
                                                             recipe.dosisAmount,
                                                             recipe.dosisType,
                                                             recipe.patientParent]
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(AlertOkKey, StringTable, nil)
                                          otherButtonTitles:NSLocalizedStringFromTable(AlertSnoozeKey, StringTable, nil), nil];
    alert.delegate = self;
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Medikit" withExtension:@"momd"];
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"medikit" withExtension:@"mom" subdirectory:@"Medikit.momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Medikit.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        // If user presses Done, recipe will show next scheduled notification
        case DoneButtonIndex:
            [RecipeNotificationHelper setLocalNotificationForRecipe:self.recipeForAlert];
            break;
            
        // If the user chooses to snooze, a notification will show 10 minutes later
        case SnoozeButtonIndex:
            [RecipeNotificationHelper setLocalNotificationForRecipe:self.recipeForAlert atTime:[[NSDate date] dateByAddingTimeInterval:TenMinutes]];
            break;
    }
}

@end
