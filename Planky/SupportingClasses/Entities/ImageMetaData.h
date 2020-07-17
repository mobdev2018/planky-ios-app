//
//  ImageMetaData.h
//  BackUpRestore
//
//  Created by Avnish Chuchras on 4/13/15.
//  Copyright (c) 2015 NIIT Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageMetaData : NSObject

@property (nonatomic) NSString *imageName;
@property (nonatomic) NSString *imagePath;
@property (nonatomic) NSString *imageURL;


@property (nonatomic) NSString *imageBackUpPathString;
@property (nonatomic) NSInteger isImageBackUp;

@end
