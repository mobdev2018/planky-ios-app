//
//  CMViewLayerModifier.h
//  AspireHHO
//
//  Created by Neelesh on 3/26/15.
//  Copyright (c) 2012 neelesh_aggarwal@yahoo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewLayerModifier : NSObject

+ (void)addShadowToView:(UIView*)view opacity:(CGFloat)opacity radius:(CGFloat)radius color:(UIColor*)color andOffset:(CGSize)offset;

+ (void)addBorderToView:(UIView*)view width:(CGFloat)width color:(UIColor*)color andCornerRadius:(CGFloat)cornerRadius;

+ (void)addGradientToView:(UIView*)view highColor:(UIColor*)highColor lowColor:(UIColor*)lowColor andCornerRadius:(CGFloat)cornerRadius;

+ (void)setBackgroundTextureForView:(UIView *)view;

// Add Corners to view
+ (void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii toView:(UIView *)view;

+ (void)addGradientArrayToView:(UIView*)view withArray:(NSArray *)colors andCornerRadius:(CGFloat)cornerRadius;

+ (void)addGradientToButton:(UIButton*)view highColor:(UIColor*)highColor lowColor:(UIColor*)lowColor andCornerRadius:(CGFloat)cornerRadius;

+ (void)addGradientArrayToButton:(UIButton*)view withArray:(NSArray *)colors andCornerRadius:(CGFloat)cornerRadius;

// Create image from color
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
