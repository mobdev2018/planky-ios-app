//
//  PieChatView.m
//  CarBuddy
//
//  Created by VS on 01/10/15.
//  Copyright (c) 2015 VS. All rights reserved.
//

#import "PieChatView.h"
#import "Pie.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)


@implementation PieChatView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.context = UIGraphicsGetCurrentContext();           // Context to draw in
    
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    
    // Enumerate through array
    for (Pie *pie in self.pieCharts) {
        [self drawBezierPathWithPie:pie withCenterPoint:centerPoint];
    }
    
}

- (void)drawBezierPathWithPie:(Pie *)pie withCenterPoint:(CGPoint)centerPoint {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:pie.radius startAngle:DEGREES_TO_RADIANS(pie.startAngle) endAngle:DEGREES_TO_RADIANS(pie.endAngle) clockwise:pie.isClockWise];
    path.lineWidth = pie.arcWidth;      // Arc Color
    [pie.strokeColor setStroke]; // Stroke Color
    
    [path stroke];
    CGContextStrokePath(self.context);
    [path closePath];
        
    if (!self.bezirePathArray)
        self.bezirePathArray = [[NSMutableArray alloc] init];
    
    [self.bezirePathArray addObject:path];
    
    if ([self.delegate respondsToSelector:@selector(arcDrawFinishedAtPoint:)]) {
        [self.delegate arcDrawFinishedAtPoint:path.currentPoint];
    }
}


#pragma mark - Add Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    UIColor *touchedColor = [self colorOfPoint:touchPoint];
    
    if ([self.delegate respondsToSelector:@selector(pieChartSelectedColor:)]) {
        [self.delegate pieChartSelectedColor:touchedColor];
    }
}

- (UIColor *) colorOfPoint:(CGPoint)point {
    unsigned char pixel[4] = {0};
    
    //CGColorSpaceRef colorSpace = CGColorGetColorSpace([UIColor greenColor].CGColor);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

@end
