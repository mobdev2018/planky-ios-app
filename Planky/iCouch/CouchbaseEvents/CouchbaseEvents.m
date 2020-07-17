//
//  CouchbaseEvents.m
//  Planky
//
//  Created by Neelesh Aggarwal on 22/11/15.
//  Copyright © 2015 Neelesh Aggarwal. All rights reserved.
//

#import "CouchbaseEvents.h"
#import "Photo.h"
//#import <CouchbaseLite/CBLModel.h>

static User *currentUser;

@implementation CouchbaseEvents


#pragma mark - User Accessors

// Get curren user
- (User *)current {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UserDocumentID]) {
        currentUser = [self findByDocumentId:[[NSUserDefaults standardUserDefaults] objectForKey:UserDocumentID]];
    }
    
    return currentUser;
}

// Find user by email on server
- (User *)findByDocumentId:(NSString *)documentId {
    CBLQuery *query = [[[DataStore currentDatabase] viewNamed:UserByNameView] createQuery];
    query.keys = @[documentId];
    NSDictionary *values = [[[query run:nil] nextRow] value];
    if (values) {
        return [User modelForDocumentWithId: values[@"_id"]];
    } else {
        return nil;
    }
}

// Get email from user defaults
- (NSString *) emailFromSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey: UserEmailSettingsKey];
}

// Login user via email
- (BOOL)loginWithEmail:(NSString *)userEmail {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject: userEmail forKey: UserEmailSettingsKey];
    [settings synchronize];
    
    return [self current] != nil;
}

// Logout user
- (void)logout {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey: UserDocumentID];
    [settings synchronize];
}


#pragma mark - User Login

- (User *)loginUserWithEmail:(NSString *)email andPassword:(NSString *)password {
    User *user = nil;
//    if (userData) {
//        user = [self saveUserResponseDetails:userData];
//    }
    return user;
}

- (User *)saveUserResponseDetails:(NSDictionary *)response {
    
    if ([response objectForKey:@"name"]) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
        [properties setValue: @"User" forKey: @"type"];
        
        for (NSString *property in @[@"name", @"cookie", @"ok"]) {
            [properties setValue: response[property] forKey: property];
        }
        
        CBLDocument* doc = [[DataStore currentDatabase] documentWithID:[response objectForKey:@"name"]];
        NSError* error;
        [doc putProperties: properties error: &error];
        
        // Save user document id
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"name"] forKey:UserDocumentID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return [User modelForDocument:doc];
    }
    else {
        return nil;
    }
}

+ (void)savePhotoDetails:(NSDictionary *)response {
    
    NSArray *rows = [response objectForKey:@"rows"];
    
    if ([rows count] > 0) {
        
        for (NSDictionary *dict in rows) {
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            [properties setValue: @"Photo" forKey: @"type"];
            
            for (NSString *property in @[@"_id", @"_rev", @"c_date", @"img_id", @"lat", @"long", @"m_date", @"p_height", @"p_width", @"size"]) {
                [properties setValue: dict[property] forKey: property];
            }
            
            CBLDocument* doc = [[DataStore currentDatabase] documentWithID:@"Photo"];
            NSError* error;
            [doc putProperties: properties error: &error];
            
            // Save user document id
            [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"name"] forKey:UserDocumentID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

//+ (Photo *)getPhotoForId:(NSString *)photoId {
//    
//}

+ (NSArray *)getAllPhotos {
    CBLQuery *query = [[[DataStore currentDatabase] viewNamed:PhotoByIdView] createQuery];
    query.keys = @[@"Photo"];
    NSDictionary *values = [[[query run:nil] nextRow] value];
    if (values) {
        return [User modelForDocumentWithId: values[@"_id"]];
    } else {
        return nil;
    }
}


#pragma mark - User Creation 

- (void)registerUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email
                      andPassword:(NSString *)password {
//    User *user = nil;
//    NSDictionary *userData = [AutheticationRequest createUserWithFirstName:firstName lastName:lastName email:email andPassword:password];
//    if (userData) {
//        user = [self saveUserResponseDetails:userData];
//    }
}


#pragma mark - Photo Creation

- (void)addPhotoWithDetails:(NSMutableDictionary *)imageDictionary {
    
    
    
}


@end
