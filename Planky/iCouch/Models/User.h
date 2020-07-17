//
//  User.h
//  iCouchBlog
//
//  Created by Anna Lesniak on 10/16/12.
//  Copyright (c) 2012 Anna Lesniak. All rights reserved.
//

#import "BaseModel.h"

@interface User : BaseModel

@property (strong, nonatomic) NSString * cookie;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * ok;

- (NSString *)documentID;

@end
