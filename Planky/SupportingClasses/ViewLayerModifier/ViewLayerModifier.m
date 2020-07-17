//
//  CMViewLayerModifier.m
//  AspireHHO
//
//  Created by Neelesh on 3/26/15.
//  Copyright (c) 2012 neelesh_aggarwal@yahoo.com. All rights reserved.
//

#import "ViewLayerModifier.h"

#define MyGradientLayerName @"MyGradient"

@implementation ViewLayerModifier

#pragma mark - Gradient, Shadow and Border

+ (void)addShadowToView:(UIView*)view opacity:(CGFloat)opacity radius:(CGFloat)radius color:(UIColor*)color andOffset:(CGSize)offset
{
    view.layer.shadowOpacity = opacity;   
    view.layer.shadowRadius  = radius;
    view.layer.shadowColor   = color.CGColor;
    view.layer.shadowOffset  = offset;
}

+ (void)addBorderToView:(UIView*)view width:(CGFloat)width color:(UIColor*)color andCornerRadius:(CGFloat)cornerRadius
{
    view.layer.borderWidth   = width;   
    view.layer.borderColor   = color.CGColor;
    view.layer.cornerRadius  = cornerRadius;
    
    view.layer.masksToBounds = YES;
}
+ (void)addGradientArrayToButton:(UIButton*)view withArray:(NSArray *)colors andCornerRadius:(CGFloat)cornerRadius
{
    //turning off bounds clipping allows the shadow to extend beyond the rect of the view
    [view setClipsToBounds:YES];
    
    //The gradient, simply enough.  It is a rectangle
    CAGradientLayer * gradient = [CAGradientLayer layer];
    [gradient setFrame:[view bounds]];
    
    NSMutableArray *actualArrayToPass=[[NSMutableArray alloc] initWithCapacity:[colors count]];
    
    for(id color in colors) {
        if([color isKindOfClass:[UIColor class]]){
            [actualArrayToPass addObject:(id)[color CGColor]];
        }
    }
    
    [gradient setColors:actualArrayToPass];
    
    //the rounded rect, with a corner radius of 6 points.
    //this *does* maskToBounds so that any sublayers are masked
    //this allows the gradient to appear to have rounded corners
    CALayer * roundRect = [CALayer layer];
    [roundRect setFrame:[view bounds]];
    [roundRect setCornerRadius:cornerRadius];
    [roundRect setMasksToBounds:YES];
    [roundRect addSublayer:gradient];
    roundRect.name = MyGradientLayerName;
    
    
    //add the rounded rect layer underneath all other layers of the view
    CALayer *pGradientLayer = nil;
    NSArray *ar = view.layer.sublayers;
    for (CALayer *pLayer in ar)
    {
        if ([pLayer.name isEqualToString:MyGradientLayerName])
        {
            pGradientLayer = pLayer;
            break;
        }
    }
    if (!pGradientLayer) [view.layer insertSublayer:roundRect below:view.imageView.layer];
    else [view.layer replaceSublayer:pGradientLayer with:roundRect];
    
    //[[view layer] insertSublayer:roundRect atIndex:0];
}

+ (void)addGradientToButton:(UIButton*)view highColor:(UIColor*)highColor lowColor:(UIColor*)lowColor andCornerRadius:(CGFloat)cornerRadius
{
    //turning off bounds clipping allows the shadow to extend beyond the rect of the view
    //[view setClipsToBounds:YES];
    
    //The gradient, simply enough.  It is a rectangle
    CAGradientLayer * gradient = [CAGradientLayer layer];
    [gradient setFrame:[view bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
    
    //the rounded rect, with a corner radius of 6 points.
    //this *does* maskToBounds so that any sublayers are masked
    //this allows the gradient to appear to have rounded corners
    CALayer * roundRect = [CALayer layer];
    [roundRect setFrame:[view bounds]];
    [roundRect setCornerRadius:cornerRadius];
    [roundRect setMasksToBounds:YES];
    [roundRect addSublayer:gradient];
    roundRect.name = MyGradientLayerName;
    
    //add the rounded rect layer underneath all other layers of the view
    CALayer *pGradientLayer = nil;
    NSArray *ar = view.layer.sublayers;
    for (CALayer *pLayer in ar)
    {
        if ([pLayer.name isEqualToString:MyGradientLayerName])
        {
            pGradientLayer = pLayer;
            break;
        }
    }
    if (!pGradientLayer) [view.layer insertSublayer:roundRect below:view.imageView.layer];
    else [view.layer replaceSublayer:pGradientLayer with:roundRect];
    
    //[[view layer] insertSublayer:roundRect atIndex:0];
}

+ (void)addGradientToView:(UIView*)view highColor:(UIColor*)highColor lowColor:(UIColor*)lowColor andCornerRadius:(CGFloat)cornerRadius
{
    //turning off bounds clipping allows the shadow to extend beyond the rect of the view
    [view setClipsToBounds:YES];
    
    //The gradient, simply enough.  It is a rectangle
    CAGradientLayer * gradient = [CAGradientLayer layer];
    [gradient setFrame:[view bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
    
    //the rounded rect, with a corner radius of 6 points.
    //this *does* maskToBounds so that any sublayers are masked
    //this allows the gradient to appear to have rounded corners
    CALayer * roundRect = [CALayer layer];
    [roundRect setFrame:[view bounds]];
    [roundRect setCornerRadius:cornerRadius];
    [roundRect setMasksToBounds:YES];
    [roundRect addSublayer:gradient];
    roundRect.name = MyGradientLayerName;
    
    //add the rounded rect layer underneath all other layers of the view
    CALayer *pGradientLayer = nil;
    NSArray *ar = view.layer.sublayers;
    for (CALayer *pLayer in ar)
    {
        if ([pLayer.name isEqualToString:MyGradientLayerName])
        {
            pGradientLayer = pLayer;
            break;
        }
    }
    if (!pGradientLayer) [view.layer insertSublayer:roundRect atIndex:0];
    else [view.layer replaceSublayer:pGradientLayer with:roundRect];

    //[[view layer] insertSublayer:roundRect atIndex:0];
}

+ (void)addGradientArrayToView:(UIView*)view withArray:(NSArray *)colors andCornerRadius:(CGFloat)cornerRadius
{
    //turning off bounds clipping allows the shadow to extend beyond the rect of the view
    [view setClipsToBounds:YES];
    
    //The gradient, simply enough.  It is a rectangle
    CAGradientLayer * gradient = [CAGradientLayer layer];
    [gradient setFrame:[view bounds]];
    
    NSMutableArray *actualArrayToPass=[[NSMutableArray alloc] initWithCapacity:[colors count]];
    
    for(id color in colors) {
        if([color isKindOfClass:[UIColor class]]){
            [actualArrayToPass addObject:(id)[color CGColor]];
        }
    }
    
    [gradient setColors:actualArrayToPass];
    
    //the rounded rect, with a corner radius of 6 points.
    //this *does* maskToBounds so that any sublayers are masked
    //this allows the gradient to appear to have rounded corners
    CALayer * roundRect = [CALayer layer];
    [roundRect setFrame:[view bounds]];
    [roundRect setCornerRadius:cornerRadius];
    [roundRect setMasksToBounds:YES];
    [roundRect addSublayer:gradient];
    roundRect.name = MyGradientLayerName;
    
    
    //add the rounded rect layer underneath all other layers of the view
    CALayer *pGradientLayer = nil;
    NSArray *ar = view.layer.sublayers;
    for (CALayer *pLayer in ar)
    {
        if ([pLayer.name isEqualToString:MyGradientLayerName])
        {
            pGradientLayer = pLayer;
            break;
        }
    }
    if (!pGradientLayer) [view.layer insertSublayer:roundRect atIndex:0];
    else [view.layer replaceSublayer:pGradientLayer with:roundRect];
    
    //[[view layer] insertSublayer:roundRect atIndex:0];
}



+ (void)setBackgroundTextureForView:(UIView *)view {
    [ViewLayerModifier addGradientToView:view highColor:[UIColor colorWithRed:64/255.0 green:11/255.0 blue:60/255.0 alpha:1.0] lowColor:[UIColor colorWithRed:64/255.0 green:11/255.0 blue:60/255.0 alpha:0.6] andCornerRadius:0];
}

+ (void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii toView:(UIView *)view {
    CALayer *tMaskLayer = [self maskForRoundedCorners:corners withRadii:radii toView:view];
    view.layer.mask = tMaskLayer;
}

+ (CALayer*)maskForRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii toView:(UIView *)view {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:
                                 maskLayer.bounds byRoundingCorners:corners cornerRadii:radii];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [roundedPath CGPath];
    
    return maskLayer;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
