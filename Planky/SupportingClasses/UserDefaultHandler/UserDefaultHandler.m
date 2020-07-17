//
//  UserDefaultHandler.m
//  Planky
//
//  Created by Neelesh on 30/10/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "UserDefaultHandler.h"

@implementation UserDefaultHandler

+ (void)setValue:(NSString *)value ForKey:(NSString *)keyName {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)valueForKey:(NSString *)keyName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyName];
}

@end
