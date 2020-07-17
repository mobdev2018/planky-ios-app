//
//  CouchbaseEvents.h
//  Planky
//
//  Created by Neelesh Aggarwal on 22/11/15.
//  Copyright © 2015 Neelesh Aggarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CouchbaseEvents : NSObject

// Current user
- (User *)current;

// Find user by email
//- (User *)findByEmail:(NSString *)anEmail;

- (NSString *)emailFromSettings;

// Login user
- (User *)loginUserWithEmail:(NSString *)email andPassword:(NSString *)password;
- (User *)saveUserResponseDetails:(NSDictionary *)hash;
- (BOOL)loginWithEmail:(NSString *)userEmail;

// Logout user
- (void)logout;

// Create new user
- (void)registerUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email
                      andPassword:(NSString *)password;

// Add new photo
+ (void)savePhotoDetails:(NSDictionary *)response;

+ (NSArray *)getAllPhotos;

@end
