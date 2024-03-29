//
//  CalculatorViewController.m
//  McAvoyCalculator
//
//  Created by Danielle McAvoy on 2/8/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphingCalculatorViewController.h"

@interface CalculatorViewController ()
@property (nonatomic,strong) CalculatorBrain *brain;

// Keeps track of if the user is inputing a number
@property (nonatomic) BOOL userIsInTheMiddleOfTypingANumber;

// keeps track of if last input was a variable
@property(nonatomic) BOOL userJustInputAVariable;
@end

@implementation CalculatorViewController
@synthesize userIsInTheMiddleOfTypingANumber =
_userIsInTheMiddleOfTypingANumber;

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Calculator";
    // tell the detail view to put the button up
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
    /*
    In searching for help with bounding boxes found this http://stackoverflow.com/questions/6233356/size-of-popover-in-a-uiviewcontroller */
    
    CGRect boundingRect = CGRectZero;
    for (UIView *view in self.view.subviews) {
        boundingRect = CGRectUnion(view.frame, boundingRect);
    }
    pc.popoverContentSize = boundingRect.size;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // tell the detail view to put the button away
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

-(CalculatorBrain*) brain{
    // keeps from creating multiple brains
    if(!_brain) _brain  = [[CalculatorBrain alloc]init];
    return _brain;
}

/* STANDARD VIEW METHODS */

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 Makes it so the brain is passed from one viewController to the other
 so that we can get the information from the previous brain.
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    {
        if ([segue.identifier isEqualToString:@"Graph"]) {
            ((GraphingCalculatorViewController*)segue.destinationViewController).brain = self.brain;
        }
    }
}

/*
 Creates a floating point number if one has not been started by
 making it 0.  instead of just .  Also makes sure that there is
 not already a . so we dont end up with 14.9.9.0 .
 
 Parameter
 point -> the point we are going to update
 
 Returns
 NSString -> either . , 0. , or blank
 
 (Hidden Method)
 */

-(NSString *)creatingFloatingPointNumber:(NSString *)point{
    NSRange range = [[self.display text] rangeOfString:point];
    if (range.location == NSNotFound) {
        if (!self.userIsInTheMiddleOfTypingANumber) {
            point = [@"0"stringByAppendingString:point];
        }
    }
    else{
        point = @"";
    }
    return point;
}

- (IBAction)digitPressed:(UIButton*)sender{
    NSString *digit = [sender currentTitle];
    
    // Allows user to input variable followed by number
    if(self.userJustInputAVariable){
        [self.brain performOperation:@"*"];
        self.userJustInputAVariable = NO;
    }
    
    // Floating point
    if ([digit isEqual:@"."]){
        digit =[self creatingFloatingPointNumber:digit];
    }
    
    // Answer display Window
    if (self.userIsInTheMiddleOfTypingANumber) {
        [self.display setText:[[self.display text] stringByAppendingString:digit]];
    }else{
        [self.display setText:digit];
        self.userIsInTheMiddleOfTypingANumber = YES;
    }
    
    // Equation Display Window
    
    // Make sure that we actually have created a string and that
    // the equal sign was not the last operation done
    if (!self.brain.equationDisplayText || self.brain.startDisplayOver) {
        self.brain.equationDisplayText = @"";
        // should we update expression?
        self.brain.startDisplayOver = NO;
    }
    self.brain.equationDisplayText = [self.brain.equationDisplayText stringByAppendingString:digit];
    
    /* Once we have variables in our expression the display starts showing the whole expression using descriptionOfExpression:. Check whether the current expression has any variables in it.
     */
    if ([CalculatorBrain variablesInExpression:self.brain.expression]) {
        self.equationDisplay.text = [CalculatorBrain descriptionOfExpression:self.brain.expression];
    }
    else {
        self.equationDisplay.text = [self.brain equationDisplayText];
    }
}

- (IBAction)operationPressed:(UIButton*)sender {
    
    self.userJustInputAVariable = NO;
    
    // If somehow we got here without entering a number
    // Fail nicely
    if(!self.brain.equationDisplayText){
        self.brain.equationDisplayText = @"0";
    }
    
    // If the equals was pressed lets just show result and the rest of
    // the equation they will enter using it
    if(self.brain.startDisplayOver){
        self.brain.equationDisplayText = [NSString stringWithFormat:@"%f", self.brain.operand];
        self.brain.startDisplayOver = NO;
    }
    
    //Takes in the number the user has entered
    if(self.userIsInTheMiddleOfTypingANumber){
        [self.brain pushOperand:[[self.display text]doubleValue]];
        self.userIsInTheMiddleOfTypingANumber = NO;
    }
    
    // Makes calculator actually calculate
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    
    /* Once we have variables in our expression the display starts showing the whole expression using descriptionOfExpression:. Check whether the current expression has any variables in it.
     */
    if ([CalculatorBrain variablesInExpression:self.brain.expression]) {
        self.equationDisplay.text = [CalculatorBrain descriptionOfExpression:self.brain.expression];
    }
    else {
        self.equationDisplay.text = [self.brain equationDisplayText];
        // Makes the result show up
        self.display.text = resultString;
        
        self.memoryDisplay.text = [NSString stringWithFormat: @"%f", self.brain.storageNumber];
    }
}

- (IBAction)clearPressed:(UIButton *)sender {
    
    self.userIsInTheMiddleOfTypingANumber = NO;
    self.userJustInputAVariable = NO;
    
    // Get brain to reset everything
    [self.brain clearVariables];
    
    // Reset the Displays
    [self.display setText:@"0"];
    self.equationDisplay.text = [self.brain equationDisplayText];
    self.memoryDisplay.text = [NSString stringWithFormat: @"%f", self.brain.storageNumber];
    
}

- (GraphingCalculatorViewController *)splitViewCalculatorViewController
{
    id hvc = [self.splitViewController.viewControllers lastObject];
    if (![hvc isKindOfClass:[GraphingCalculatorViewController class]]) {
        hvc = nil;
    }
    return hvc;
}

- (IBAction)graphPressed:(UIButton *)sender {
    
    // If all we put in is a variable we need to override purpose of
    // startDisplayOver
    if (self.userJustInputAVariable) {
        [self.brain performOperation:@"="];
    }
    
    self.userJustInputAVariable = NO;
    
    //Takes in the number the user has entered
    if(self.userIsInTheMiddleOfTypingANumber){
        [self.brain pushOperand:[[self.display text]doubleValue]];
        self.userIsInTheMiddleOfTypingANumber = NO;
    }
    
    // Make sure we actually get the correct value even if we
    // didn't press equals before
    if (!self.brain.startDisplayOver) {
        [self.brain performOperation:@"="];
    }
    
    if ([self splitViewController]) {
        GraphingCalculatorViewController *gcvc = [self splitViewCalculatorViewController];
        gcvc.brain = self.brain;
        [gcvc.graphView setNeedsDisplay];
    }
    
    /* Set the display to a string with the expression and
     result */
    self.equationDisplay.text = [NSString stringWithFormat:@"%@", [CalculatorBrain descriptionOfExpression:self.brain.expression]];
    self.display.text = 0;
}

- (IBAction)variablePressed:(UIButton *)sender {
    
    self.userJustInputAVariable = YES;
    
    // If you were entering a number and then hit variable
    // We want to stop entering that variable and we also
    // want this to be treated like multiplication
    if(self.userIsInTheMiddleOfTypingANumber){
        [self.brain pushOperand:[[self.display text]doubleValue]];
        [self.brain performOperation:@"*"];
        self.userIsInTheMiddleOfTypingANumber = NO;
    }
    
    [self.brain setVariableAsOperand:sender.currentTitle];
    self.equationDisplay.text = [CalculatorBrain descriptionOfExpression:self.brain.expression];
    
}
@end