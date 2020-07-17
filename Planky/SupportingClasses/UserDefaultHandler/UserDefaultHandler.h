//
//  UserDefaultHandler.h
//  Planky
//
//  Created by CanvasM on 30/10/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultHandler : NSObject

+ (void)setValue:(NSString *)value ForKey:(NSString *)keyName;
+ (id)valueForKey:(NSString *)keyName;

@end
