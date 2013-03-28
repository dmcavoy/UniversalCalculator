//
//  GraphingCalculatorViewController.m
//  McAvoyGraphingCalculator
//
//  Created by Danielle McAvoy on 3/2/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

#import "GraphingCalculatorViewController.h"

@interface GraphingCalculatorViewController ()

@end

@implementation GraphingCalculatorViewController

-(CalculatorBrain*) brain{
    // keeps from creating multiple brains
    if(!_brain) _brain  = [[CalculatorBrain alloc]init];
    return _brain;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.graphView.delegate = self;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer * doubleTapped =[[UITapGestureRecognizer alloc]initWithTarget:self.graphView action:@selector(doubleTap:)];
    [doubleTapped setNumberOfTapsRequired:2];
    [self.graphView addGestureRecognizer:doubleTapped];
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    [self.graphView setNeedsDisplay];
}

/*
 Gets the y value that corresponds with the current x value. 
 
 Parameters
 requestor -> the GraphView asking for help
 x -> the x value
 
 Return
 CGPoint -> the (x,y) point calculated
 */
-(CGPoint)nextYForGraphView:(GraphView *)requestor usingXValue:(float)x{
    CGPoint point = CGPointMake(0, 0);
    if (requestor == self.graphView){
        point.x = x;
        NSDictionary * xValue = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithFloat:x] , @"x", nil];
        point.y = [CalculatorBrain evaluateExpression:self.brain.expression usingVariableValues: xValue];
    }
    return point;
}

@end
