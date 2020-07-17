//
//  User.m
//  iCouchBlog
//
//  Created by Anna Lesniak on 10/16/12.
//  Copyright (c) 2012 Anna Lesniak. All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"

@implementation User

@dynamic name, cookie, ok;

+ (void) defineFilters {}

- (NSString *) documentID {
  return [[self document] documentID];
}


@end
