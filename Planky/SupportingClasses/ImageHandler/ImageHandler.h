//
//  ImageHandler.h
//  DataCachePOC
//
//  Created by Neelesh on 06/02/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageHandler : NSObject

/**
 Passed Parameter:  UIImage, referenceId(For Name)
 Return Parameter:  nil
 Saves image to cache folder with provided reference id
 */
+ (void)saveImage:(UIImage *)image withId:(NSString *)referenceId;

/**
 Passed Parameter:  UIImage, referenceId(For Name) Folder Name
 Return Parameter:  nil
 Saves image to cache folder with provided reference id
 */
+ (void)saveImage:(UIImage *)image withId:(NSString *)referenceId inFolder:(NSString *)folderName;

/**
 Passed Parameter:  referenceId (Image Name)
 Return Parameter:  UIImage
 Returns image with passed referenceID
 */
+ (UIImage *)getImageForId:(NSString *)referenceId;

/**
 Passed Parameter:  referenceId (Image Name) Folder Name
 Return Parameter:  UIImage
 Returns image with passed referenceID
 */
+ (UIImage *)getImageForId:(NSString *)referenceId fromFolder:(NSString *)folderName;

/**
 Passed Parameter:  referenceId (Image Name)
 Return Parameter:  UIImage
 Returns image with passed referenceID
 */
+ (NSString *)getImagePathForReferenceId:(NSString *)referenceId;


/**
 Passed Parameter:  nil
 Return Parameter:  nil
 Clear image cache
 */
+ (void)deleteAllCachedImages;


/**
 Passed Parameter:  image, sizeToScale
 Return Parameter:  Scaled Image
 Scales image according to the new size
 */
+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)newSize;

/**
 Passed Parameter:  Folder name
 Return Parameter:  Array of file names
 Searches all files inside a folder and return list of all file names
 */
+ (NSArray *)getFilesListForFolder:(NSString *)folderName;


+ (NSString *)getPathForFolder:(NSString *)folderName;

@end
