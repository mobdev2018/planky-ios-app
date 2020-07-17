//
//  AppDelegate.h
//  Planky
//
//  Created by Neelesh Aggarwal on 30/10/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DropBox.h"
#import "Reachability.h"

#define kDatabaseName   @"planky"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) Reachability * internetReachable;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) CBLDatabase *database;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// Show and hide loading indicator
- (void)showProgressViewOnView:(UIView *)view;
- (void)hideProgressViewFromView:(UIView *)view;

@end

