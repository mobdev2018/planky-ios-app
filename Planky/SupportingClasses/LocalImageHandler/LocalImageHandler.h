//
//  LocalImageHandler.h
//  Planky
//
//  Created by CanvasM on 09/12/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalImageHandler : NSObject

+ (NSDictionary *)getImageDetailsForId:(NSString *)imgId;

+ (void)addMultipleImageIdsToFile:(NSArray *)imageIds isDeleted:(BOOL)isDeleted;

+ (void)addImageDetailsToFile:(NSDictionary *)imageDict isDeleted:(BOOL)isDeleted;

+ (void)addImageIdToFile:(NSString *)imageId isDeleted:(BOOL)isDeleted;

+ (NSArray *)getAllImageIdsToDelete;

@end
