//
//  PieChatView.h
//  CarBuddy
//
//  Created by VS on 01/10/15.
//  Copyright (c) 2015 VS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PieChatDelegate <NSObject>

@optional

// Pie chart color selected
- (void)pieChartSelectedColor:(UIColor *)selectedColor;

// Arc draw finished at point
- (void)arcDrawFinishedAtPoint:(CGPoint)point;

@end

@interface PieChatView : UIView

@property (nonatomic, assign) CGContextRef          context;        // Drawing context

@property (nonatomic, strong) NSMutableArray*       pieCharts;      // Pie array
@property (nonatomic, strong) NSMutableArray*       bezirePathArray; // Array to hold all bezier paths

@property (nonatomic, assign) id                    delegate;

@end
