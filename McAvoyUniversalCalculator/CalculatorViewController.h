//
//  CalculatorViewController.h
//  McAvoyCalculator
//
//  Created by Danielle McAvoy on 2/8/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

/*
 This is the ViewController for the main calculator page. It responds to the buttons on the screen and updates displays which are UILabels. This is the controller for our MVC so it then calls on the brain to use the information it has to do all of the work.
 */

#import <UIKit/UIKit.h>
#import "GraphingCalculatorViewController.h"

@interface CalculatorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *equationDisplay;
@property (weak, nonatomic) IBOutlet UILabel *memoryDisplay;

- (IBAction)variablePressed:(UIButton *)sender;

/*
 Takes in the numbers as pressed and puts them
 in the display.  Deals with floating points
 to make sure you don't enter more than one .
 and there is not a . without at least a 0 in
 front of it.
 */
- (IBAction)digitPressed:(UIButton*)sender;


/* Responds to operation button pressed.
 Sends to the brain the information about
 the digit once it has been fully entered.
 Then it gets the result of the operation from
 the brain and resets the displays.
 */
- (IBAction)operationPressed:(UIButton*)sender;


// Resets the calculator to its orginal state
- (IBAction)clearPressed:(UIButton *)sender;

/*
 Creates a dictionary that holds the variables and some test values for
 each of the variables. We then use the dictionary to evaluate the expression.
 */
- (IBAction)graphPressed:(UIButton *)sender;

@end