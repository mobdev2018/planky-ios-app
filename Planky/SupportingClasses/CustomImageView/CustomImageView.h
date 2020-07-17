//
//  CustomImageView.h
//  Planky
//
//  Created by CanvasM on 27/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomImageView : UIImageView
@property (nonatomic, strong) UIVisualEffectView*       mBlurView;
@property (nonatomic, strong) UIView*                   mBlackView;
@property (nonatomic, strong) NSTimer*      imageTimer;

- (void) setBlackViewRect:(CGRect)frame withIsBlur:(BOOL)isBlur;
-(void)setBlur:(BOOL)isBlur;

@end
