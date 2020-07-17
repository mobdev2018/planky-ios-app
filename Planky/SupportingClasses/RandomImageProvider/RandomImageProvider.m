//
//  RandomImageProvider.m
//  Planky
//
//  Created by CanvasM on 27/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "RandomImageProvider.h"
#import "ImageHandler.h"

@implementation RandomImageProvider

+ (id)sharedManager {
    static RandomImageProvider *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        // Get image array
        self.imageArray = [ImageHandler getFilesListForFolder:@"Image"];
    }
    return self;
}


#pragma mark - Random Image Reference

// Extracts any random image
- (NSString *)getRandomImageName {
    if ([self.imageArray count] > 0) {
        NSInteger randomNumber = arc4random()%[self.imageArray count];
        return [self.imageArray objectAtIndex:randomNumber];
    }
    return nil;
}

// Reload imaages array
- (void)reloadImagesArray {
    self.imageArray = [ImageHandler getFilesListForFolder:@"Image"];
}

@end
