//
//  ImageHandler.m
//  AspireHHO
//
//  Created by Neelesh on 3/26/15.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ImageHandler.h"

@implementation ImageHandler

#pragma mark - Image Save Methods

// To Be used
+ (void)saveImage:(UIImage *)image withId:(NSString *)referenceId {
    
    if (!referenceId)
        return;
    
    NSMutableString *referencePath = [ImageHandler checkFolderPathForId:referenceId];
    
    [referencePath appendFormat:@"/%@", [referenceId lastPathComponent]];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [imageData writeToFile:referencePath atomically:NO];
}

+ (void)saveImage:(UIImage *)image withId:(NSString *)referenceId inFolder:(NSString *)folderName {
    
    //Get Folder path
    NSString *folderPath = [ImageHandler getPathForFolder:folderName];
    
    //Create Image Path
    NSString *imagePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", referenceId]];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [imageData writeToFile:imagePath atomically:NO];
}


#pragma mark - Image Get Methods

// To be used
+ (UIImage *)getImageForId:(NSString *)referenceId {
    
    if (!referenceId)
        return nil;
    
    //Get Folder path
    NSMutableString *referencePath = [ImageHandler checkFolderPathForId:referenceId];
    
    [referencePath appendFormat:@"/%@", [referenceId lastPathComponent]];
    
    //Create Image from file
    UIImage *image = [UIImage imageWithContentsOfFile:referencePath];
    
    return image;
}

+ (UIImage *)getImageForId:(NSString *)referenceId fromFolder:(NSString *)folderName {
    //Get Folder path
    NSString *folderPath = [ImageHandler getPathForFolder:folderName];
    
    //Create Image Path
    NSString *imagePath = [folderPath stringByAppendingPathComponent:referenceId];
    
    //Create Image from file
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    return image;
}

+ (NSString *)getImagePathForReferenceId:(NSString *)referenceId {
    
    if (!referenceId)
        return nil;
    
    //Get Folder path
    NSMutableString *referencePath = [ImageHandler checkFolderPathForId:referenceId];
    
    [referencePath appendFormat:@"/%@", [referenceId lastPathComponent]];

    return referencePath;
}


#pragma mark - Folder Contents Methods

+ (NSArray *)getFilesListForFolder:(NSString *)folderName {
    NSString *folderPath = [ImageHandler getPathForFolder:folderName];
    NSArray *imagesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    return imagesArray;
}


#pragma mark - Image Delete Methods

+ (void)deleteAllCachedImages {
    //Get Folder path
    NSString *folderPath = [ImageHandler getImageFolderPath];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error.description);
    }
}

+ (void)deleteFolder:(NSString *)folderName {
    //Get Folder path
    NSString *folderPath = [ImageHandler getPathForFolder:folderName];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error.description);
    }
}


#pragma mark - Private Methods

// Create Folder if it is not created yet
+ (NSString *)getImageFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Image"];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    return dataPath;
}

// Get Folder path from document directory.
// Create Folder if it is not created yet
+ (NSString *)getPathForFolder:(NSString *)folderName {
    NSString *documentsDirectory = [ImageHandler getImageFolderPath];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", folderName]];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    return dataPath;
}

+ (NSString *)pathExistForFolder:(NSString *)folderName {
    NSString *documentsDirectory = [ImageHandler getImageFolderPath];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", folderName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        return nil;
    
    return dataPath;
}


#pragma mark - Resize Image

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    
    /* 
     Checking if image size is less that the required size.
     If yes, then return the same image.
     */
    if (image.size.height <newSize.height ||
        image.size.width  <newSize.width)
    {
        return image;
    }
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


#pragma mark - Private Methods

+ (NSMutableString *)checkFolderPathForId:(NSString *)referenceId {
    
    NSMutableString *folderPath = [[NSMutableString alloc] init];
    [folderPath appendString:[ImageHandler getImageFolderPath]];
    
    // Remove Http and https from string
    NSString *updatedString = [referenceId stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    updatedString = [updatedString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
    NSMutableArray *nameArray = [NSMutableArray arrayWithArray:[updatedString componentsSeparatedByString:@"/"]];
    
    if ([nameArray count] > 1) {
        
        [nameArray removeLastObject];
        
        for (NSString *folderName in nameArray) {
            [folderPath appendFormat:@"/%@", folderName];
            
            NSError *error = nil;
            if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
    }
    
    return folderPath;
}


@end
