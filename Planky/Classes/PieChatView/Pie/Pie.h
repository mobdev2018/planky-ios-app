//
//  Pie.h
//  CarBuddy
//
//  Created by VS on 01/10/15.
//  Copyright (c) 2015 VS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Pie : NSObject

@property (nonatomic, assign) CGFloat       startAngle;
@property (nonatomic, assign) CGFloat       endAngle;
@property (nonatomic, assign) CGFloat       arcWidth;
@property (nonatomic, assign) CGFloat       radius;
@property (nonatomic, strong) UIColor   *   strokeColor;
@property (nonatomic, assign) BOOL          isClockWise;
@property (nonatomic, assign) CGPoint       centerPoint;


@end
