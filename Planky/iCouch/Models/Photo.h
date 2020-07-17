//
//  Photo.h
//  Planky
//
//  Created by CanvasM on 08/12/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Photo : BaseModel

@property (strong, nonatomic) NSString * _id;
@property (strong, nonatomic) NSString * _rev;
@property (strong, nonatomic) NSString * img_id;
@property (strong, nonatomic) NSString * p_height;
@property (strong, nonatomic) NSString * p_width;
@property (strong, nonatomic) NSString * size;
@property (strong, nonatomic) NSString * user_id;
@property (strong, nonatomic) NSString * c_date;
@property (strong, nonatomic) NSString * m_date;

- (NSString *)documentID;

@end
