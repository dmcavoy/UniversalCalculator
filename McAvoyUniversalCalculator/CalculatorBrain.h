//
//  CalculatorBrain.h
//  McAvoyCalculator
//
//  Created by Danielle McAvoy on 2/8/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

/*
 CalculatorBrain is the mastermind of the calculator. The Brain does all the math for the calcultor as well as keeping track of the entire equation to display to the user. 
 
    The brain also now keeps track of the expression. 
*/

// Append this to variables so we can
// easily process them
#define VARIABLE_PREFIX @"%"

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

// Current Operand
@property (nonatomic) double operand;

// Memory Store
@property (nonatomic) double storageNumber;

// For equation display label
@property (nonatomic, strong) NSString * equationDisplayText;

@property (nonatomic) BOOL startDisplayOver;

// Public Expression
@property (readonly) id expression;



/*
 Substitutes the appropriate values into the expression for the variables and evaluate the value then returning the result.
 
 The way this is create with an instance of brain it is makes it so that we can't do memory functions because we can't access the storageValue after this brain instance dies. So what we do instead is just not let the user ever hit these once a variable has been input.
 
 Parameters:
 anExpression -> The expression containging variables to evaluate
 variables -> The Dicitionary of values to use in evaluating.  Keys are NSStrings and the values are NSNumber objects
 
 Return Value:
 double -> the result of the expression with variables actual values
 */

   
+ (double)evaluateExpression:(id)anExpression
         usingVariableValues:(NSDictionary *)variables;

/*
 Loops through expression and returns a NSSet of all the variables in the expression. Will
 only put a variable in the set once (no doubles).
 
 Parameters:
 anExpression -> The expression to check
 
 Return:
 NSSet -> Set of variables in anExpression (nil if not variables)
 
 */
+(NSSet *)variablesInExpression:(id)anExpression;

/*
 Returns an NSString which represents anExpression.
 
 Parameter:
 anExpression -> The Array of operands and operations
 
 Return:
 NSString -> the equation as a string
 */
+(NSString *)descriptionOfExpression:(id)anExpression;

/*
 Converts our expression which is a NSMutableArray into a propertyList.
 
 Parameter:
 anExpression -> the expression
 
 Return:
 propertyList-> propertyList for our expression
 
 */
+(id)propertyListForExpression:(id)anExpression;

/*
 Converts a property list into a NSMutableArray which is
 how we keep our expression.
 
 Parameter:
 propertyList-> propertyList for our expression
 
 Return:
 id -> Expression as a NSMutableArray
 */
+(id)expressionForPropertyList:(id)propertyList;




/*  Takes a variable name and adds it to the
 internalExpression. (Adds % sign infront to help
 with decoding expression later).
 
 Parameter:
 variableName -> the variable
 
 */
-(void) setVariableAsOperand:(NSString *)variableName;

/* Takes in the value of the number that
the user input before pressing the operation key 
 
 Parameters:
 aDouble -> the double the user entered
 */
-(void) pushOperand: (double)aDouble;


/* This is the heart of the caculator. It takes in an
 operation and decides how to compute the output. For
 single operand operations it does the caculation and
 returns the value right away. If it is a two operand
 operation it has to get help 
 from performWaitingOperation.
 
 It also takes care of updating the equationDisplay. The
 equation display will only reset after certain operation
 calls (=, Recall, Divid By Zero Error, Not Real Number
 Error, memory actions).
 
 Limitations:
 The method does not deal right now with if you press two
 operations in a row.
 The output display is not perfect and will sometimes look
 different than a normal calculator.
 
 Parameters:
 operation -> the operation which is to be performed
 
 Return Value:
 double -> returns the calculated value
 */
-(double)performOperation:(NSString*)operation;


// Clears everything and resets it to orginal values
-(void) clearVariables;

@end
