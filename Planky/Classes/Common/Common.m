//
//  Common.m
//  Planky
//
//  Created by beauty on 12/25/15.
//  Copyright © 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"


NSString *g_freeSpace;

@implementation Common


+(UIFont*)getFontWithFamilyName:(NSString *)fontName withFontSize:(float)fontSize
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIFont *font = [UIFont fontWithName:fontName size:fontSize * screenSize.height / 1334.0f];
    return font;
}

@end