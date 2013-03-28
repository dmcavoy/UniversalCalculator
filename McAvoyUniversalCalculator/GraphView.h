//
//  GraphView.h
//  McAvoyGraphingCalculator
//
//  Created by Danielle McAvoy on 3/2/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

/*
 Creates a graph with axes and an actual funciton 
 graph. Uses a scale so that graph can be zoomed in
 and out on.
 */

#import <UIKit/UIKit.h>
#import "AxesDrawer.h"

@class GraphView;

@protocol GraphViewDelegate <NSObject>

/*
 Gets the Y value for the x value given.
 */
-(CGPoint)nextYForGraphView:(GraphView *)requestor usingXValue:(float)x;

@end

@interface GraphView : UIView

@property (nonatomic) id <GraphViewDelegate> delegate;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;

@end
