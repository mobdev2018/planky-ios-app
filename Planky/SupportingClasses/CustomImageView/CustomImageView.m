//
//  CustomImageView.m
//  Planky
//
//  Created by CanvasM on 27/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "CustomImageView.h"
#import "RandomImageProvider.h"
#import "ImageHandler.h"

@implementation CustomImageView
@synthesize mBlurView;
@synthesize mBlackView;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        // Add black hover view
        
        // create effect
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        mBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        mBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth & UIViewAutoresizingFlexibleHeight;
        mBlurView.alpha = 0.85f;
        // add the effect view to the image view
        [self addSubview:mBlurView];
        [mBlurView setHidden:YES];
        
        mBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        mBlackView.backgroundColor = [UIColor blackColor];
        mBlackView.alpha = 0.5;
        [self addSubview:mBlackView];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        [self startImageChange];
        
        self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:ImageChangeDuration target:self selector:@selector(startImageChange) userInfo:nil repeats:YES];
    }
    
    // Start timer for image change
    
    return self;
}

-(void) setBlackViewRect:(CGRect)frame withIsBlur:(BOOL)isBlur
{
    [mBlackView setFrame:frame];
    [mBlurView setFrame:frame];
    
    [self setBlur:isBlur];
    
}

-(void)setBlur:(BOOL)isBlur
{
    if (isBlur) {
        [mBlurView setHidden:NO];
        [mBlackView setHidden:YES];
    }
    else
    {
        [mBlackView setHidden:NO];
        [mBlurView setHidden:YES];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSLog(@"Draw Called");
}


#pragma mark - Image Change Methods

- (void)startImageChange {
    
    // Check if images are in document directory
    NSString *imageName = [[RandomImageProvider sharedManager] getRandomImageName];
    
    if (!imageName) {           // Show placeholder image
        
    }
    else {
        self.image = [ImageHandler getImageForId:imageName fromFolder:@"Image"];
    }
}



@end
