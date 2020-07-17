//
//  RandomImageProvider.h
//  Planky
//
//  Created by CanvasM on 27/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomImageProvider : NSObject

@property (nonatomic, strong) NSArray*      imageArray;

// Shared class reference
+ (id)sharedManager;

// Random image name from IMAGE folder
- (NSString *)getRandomImageName;

// Reload image array
- (void)reloadImagesArray;

@end
