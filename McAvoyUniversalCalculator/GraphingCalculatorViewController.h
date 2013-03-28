//
//  GraphingCalculatorViewController.h
//  McAvoyGraphingCalculator
//
//  Created by Danielle McAvoy on 3/2/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

/*
 This is the ViewController associated with the graphView.  It allows
 you to zoom in and out on a graph that you created. The graph has axes 
 and a graph of the expression that was on the calculator when you pressed
 graph. 
 
 */

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphingCalculatorViewController : UIViewController <GraphViewDelegate>

@property (weak, nonatomic) IBOutlet GraphView *graphView;

@property (nonatomic,strong) CalculatorBrain *brain;

@end
