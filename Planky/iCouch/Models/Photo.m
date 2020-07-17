//
//  Photo.m
//  Planky
//
//  Created by CanvasM on 08/12/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@dynamic _id, _rev, img_id, p_height, p_width, size, user_id;
@synthesize m_date, c_date;

+ (void) defineFilters {}

- (NSString *) documentID {
    return [[self document] documentID];
}


@end
