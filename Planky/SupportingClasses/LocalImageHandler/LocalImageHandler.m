//
//  LocalImageHandler.m
//  Planky
//
//  Created by CanvasM on 09/12/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "LocalImageHandler.h"

#define ImagePlist      @"ImagePlist.plist"

@implementation LocalImageHandler


+ (NSDictionary *)getImageDetailsForId:(NSString *)imgId {
    
    // Check if IMAGEID or THUMBNAIL id matches
    
    // Get plist path;
    NSString *plistPath = [LocalImageHandler getPlistPathFor:ImagePlist];
    
    // Get plist data
    NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistPath];

    // Check if imageId exists in array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageId=%@ OR thumbnalId=%@", imgId, imgId];
    NSArray *filteredArray = [plistArray filteredArrayUsingPredicate:predicate];

    if ([filteredArray count] > 0)
        return [filteredArray objectAtIndex:0];
    else
        return nil;
}

#pragma mark - Multiple ImageId Accessor

+ (void)addMultipleImageIdsToFile:(NSArray *)imageIds isDeleted:(BOOL)isDeleted {
    
    // Get plist path;
    NSString *plistPath = [LocalImageHandler getPlistPathFor:ImagePlist];
    
    // Get plist data
    NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    
    // Check if imageId exists in array
    
    for (NSDictionary *imageDict in imageIds) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageId=%@", [imageDict objectForKey:@"imageId"]];
        NSArray *filteredArray = [plistArray filteredArrayUsingPredicate:predicate];
        
        NSMutableDictionary *dict = nil;
        if ([filteredArray count] > 0) {            // Already exists
            dict = [NSMutableDictionary dictionaryWithDictionary:[filteredArray objectAtIndex:0]];
            [dict setObject:@(isDeleted) forKey:@"isDeleted"];
        }
        else {          // Add new row
            dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[imageDict objectForKey:@"imageId"] forKey:@"imageId"];
            [dict setObject:@(isDeleted) forKey:@"isDeleted"];
            
            if ([imageDict objectForKey:@"latitude"])
                [dict setObject:[imageDict objectForKey:@"latitude"] forKey:@"latitude"];   // Latitude
            
            if ([imageDict objectForKey:@"longitude"])
                [dict setObject:[imageDict objectForKey:@"longitude"] forKey:@"longitude"];  // Longitude
            
            if ([imageDict objectForKey:@"creDate"])
                [dict setObject:[imageDict objectForKey:@"creDate"] forKey:@"creDate"];     // Creation Date
            
            if ([imageDict objectForKey:@"modDate"])
                [dict setObject:[imageDict objectForKey:@"modDate"] forKey:@"modDate"];     // ModificationDate Date
        }
        
        // Update array for item
        if ([plistArray containsObject:dict])
            [plistArray replaceObjectAtIndex:[plistArray indexOfObject:dict] withObject:dict];
        else
            [plistArray addObject:dict];
    }
    
    [plistArray writeToFile:plistPath atomically:YES];
}


#pragma mark - Single Image Id Accessor

+ (void)addImageIdToFile:(NSString *)imageId isDeleted:(BOOL)isDeleted {

    // Get plist path;
    NSString *plistPath = [LocalImageHandler getPlistPathFor:ImagePlist];
    
    // Get plist data
    NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    
    // Check if imageId exists in array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageId=%@", imageId];
    NSArray *filteredArray = [plistArray filteredArrayUsingPredicate:predicate];
    
    NSMutableDictionary *dict = nil;
    if ([filteredArray count] > 0) {            // Already exists
        dict = [NSMutableDictionary dictionaryWithDictionary:[filteredArray objectAtIndex:0]];
        [dict setObject:@(isDeleted) forKey:@"isDeleted"];
    }
    else {          // Add new row
        dict = [[NSMutableDictionary alloc] init];
        [dict setObject:imageId forKey:@"imageId"];
        [dict setObject:@(isDeleted) forKey:@"isDeleted"];
    }

    // Update array for item
    if ([plistArray containsObject:dict])
        [plistArray replaceObjectAtIndex:[plistArray indexOfObject:dict] withObject:dict];
    else
        [plistArray addObject:dict];
    
    
    [plistArray writeToFile:plistPath atomically:YES];
}

+ (void)addImageDetailsToFile:(NSDictionary *)imageDict isDeleted:(BOOL)isDeleted {
    
    // Get plist path;
    NSString *plistPath = [LocalImageHandler getPlistPathFor:ImagePlist];
    
    // Get plist data
    NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    
    // Check if imageId exists in array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageId=%@", [imageDict objectForKey:@"imageId"]];
    NSArray *filteredArray = [plistArray filteredArrayUsingPredicate:predicate];
    
    NSMutableDictionary *dict = nil;
    if ([filteredArray count] > 0) {            // Already exists
        dict = [NSMutableDictionary dictionaryWithDictionary:[filteredArray objectAtIndex:0]];
        [dict setObject:@(isDeleted) forKey:@"isDeleted"];
    }
    else {          // Add new row
        dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[imageDict objectForKey:@"imageId"] forKey:@"imageId"];         // Image Id
        [dict setObject:@(isDeleted) forKey:@"isDeleted"];                              // Is Deleted
        
        if ([imageDict objectForKey:@"latitude"])
            [dict setObject:[imageDict objectForKey:@"latitude"] forKey:@"latitude"];   // Latitude
        
        if ([imageDict objectForKey:@"longitude"])
            [dict setObject:[imageDict objectForKey:@"longitude"] forKey:@"longitude"];  // Longitude
        
        if ([imageDict objectForKey:@"creDate"])
            [dict setObject:[imageDict objectForKey:@"creDate"] forKey:@"creDate"];     // Creation Date
        
        if ([imageDict objectForKey:@"modDate"])
            [dict setObject:[imageDict objectForKey:@"modDate"] forKey:@"modDate"];     // ModificationDate Date

        if ([imageDict objectForKey:@"thumbnailId"])
            [dict setObject:[imageDict objectForKey:@"thumbnailId"] forKey:@"thumbnailId"];     // ModificationDate Date

    }
    
    // Update array for item
    if ([plistArray containsObject:dict])
        [plistArray replaceObjectAtIndex:[plistArray indexOfObject:dict] withObject:dict];
    else
        [plistArray addObject:dict];
    
    
    [plistArray writeToFile:plistPath atomically:YES];
}



#pragma mark - Access All Deleted Ids

+ (NSArray *)getAllImageIdsToDelete {
 
    // Get plist path;
    NSString *plistPath = [LocalImageHandler getPlistPathFor:ImagePlist];
    
    // Get plist data
    NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    
    // Check if imageId exists in array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDeleted=%@", @(NO)];
    NSArray *filteredArray = [plistArray filteredArrayUsingPredicate:predicate];
    
    return filteredArray;
}


#pragma mark - Private Methods

+ (NSString *)getPlistPathFor:(NSString *)plistName {
    // set file manager object
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // check if file exists
    NSString *plistPath = [self copyFileToDocumentDirectory:plistName];
    
    BOOL isExist = [manager fileExistsAtPath:plistPath];
    
    if (!isExist) {
        NSLog(@"Unable to create file");
        return nil;
    }
    else {
        return plistPath;
    }
}


+ (NSString *)copyFileToDocumentDirectory:(NSString *)fileName {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *documentDirPath = [documentsDir stringByAppendingPathComponent:fileName];
    
    NSArray *file = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[file objectAtIndex:0] ofType:[file lastObject]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:documentDirPath];
    
    if (!success) {
        success = [fileManager copyItemAtPath:filePath toPath:documentDirPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to create writable txt file file with message \
                      '%@'.", [error localizedDescription]);
        }
    }
    
    return documentDirPath;
}

@end
