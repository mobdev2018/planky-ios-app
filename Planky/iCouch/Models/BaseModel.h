//
//  BaseModel.h
//  iCouchBlog
//
//  Created by Anna Lesniak on 9/2/12.
//  Copyright (c) 2012 Anna Lesniak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : CBLModel

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) NSDate *updated_at;

+ (void)defineFilters;

+ (id)modelForDocumentWithId:(NSString *) docId;

@end
