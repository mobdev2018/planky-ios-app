//
//  AppDelegate.m
//  Planky
//
//  Created by Neelesh Aggarwal on 30/10/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "SlideLeftVC.h"
#import "SlideNavigationController.h"
#import "MBProgressHUD.h"
#import "ImageHandler.h"
#import "User.h"
#import "CouchbaseEvents.h"
#import "PhotoGalleryVC.h"
#import <CouchbaseLite/CBLManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    NSArray *fontFamilies = [UIFont familyNames];
//    for (int i = 0; i < [fontFamilies count]; i++)
//    {
//        NSString *fontFamily = [fontFamilies objectAtIndex:i];
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
//        NSLog(@"%@: %@", fontFamily, fontNames);
//    }
    
    
    g_freeSpace = [[NSUserDefaults standardUserDefaults] objectForKey:@"freespace"];
    
    // Dropbox
    [DropBox sharedInstance];
    
    [self setLeftMenuForDisplay];
    
    [self startNetworkReachability];
    
    [self setupDatabase];
    [self setupGeneralViews];

    // Check if user is already logged in
    CouchbaseEvents *event = [[CouchbaseEvents alloc] init];
    if ([event current]) {      // Load Photo Gallery View directly
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PhotoGalleryVC *vc = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoGalleryVC"];
        
        [(SlideNavigationController *)self.window.rootViewController pushViewController:vc animated:YES];
    }
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)setLeftMenuForDisplay {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SlideLeftVC *leftMenu = (SlideLeftVC*)[storyBoard instantiateViewControllerWithIdentifier: @"SlideLeftVC"];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
}

- (void)startNetworkReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification
     object:nil];

    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
}

- (void)checkNetworkStatus:(NSNotification *)notice {
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    NSLog(@"Network status: %i", internetStatus);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([[DBSession sharedSession] handleOpenURL:url])
    {
        if ([[DBSession sharedSession] isLinked])
        {
            NSLog(@"App linked successfully!");
        }
        return YES;
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Neelesh.Planky" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Planky" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Planky.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"OPEN_DROPBOX_VIEW" object:[NSNumber numberWithBool:[[DBSession sharedSession] isLinked]]]];
        }
        return YES;
    }
    return NO;
}


#pragma mark - Database Methods

- (void) setupDatabase {
    NSError* error;
    self.database = [[CBLManager sharedInstance] databaseNamed:kDatabaseName
                                                               error: &error];
    if (!self.database) {
        NSLog(@"Failed setuping database: %@.", [error localizedDescription]);
    }
}

- (void) setupGeneralViews {
    
    // User view
    CBLView  *view = [[DataStore currentDatabase] viewNamed: UserByNameView];
    
    [view setMapBlock: MAPBLOCK({
        NSLog(@"Value");
        NSString *type = doc[@"type"];
        id name = doc[@"name"];
        if ([type isEqualToString: @"User"] && name) emit(name, doc);
    }) reduceBlock: nil version: @"2.0"];
    
    // Photo view
    CBLView  *photoView = [[DataStore currentDatabase] viewNamed: PhotoByIdView];
    
    [photoView setMapBlock: MAPBLOCK({
        NSString *type = doc[@"type"];
        id name = doc[@"Photo"];
        if ([type isEqualToString: @"Photo"] && type && name) emit([doc objectForKey:@"_id"], doc);
    }) reduceBlock: nil version: @"2.0"];
}


#pragma mark - Loading Indicator Methods

- (void)showProgressViewOnView:(UIView *)view {
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}

- (void)hideProgressViewFromView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}


@end
