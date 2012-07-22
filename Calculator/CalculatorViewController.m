//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Mike Dunker on 6/22/12.
//  Copyright (c) 2012 Dunker Development. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringNumber;
@property (nonatomic) BOOL userHasEnteredDecimalPoint;
@property (nonatomic, strong) CalculatorBrain * brain;
@property (nonatomic, strong) NSDictionary * testVariableValues;

- (void)pushOperand:(double)operand;
- (void)pushVariableOperand:(NSString *)variableName;
- (id)performOperation:(NSString *)operation;
@end

@implementation CalculatorViewController

@synthesize display;
@synthesize historyDisplay;
@synthesize variableDisplay;
@synthesize userIsInTheMiddleOfEnteringNumber = _userIsInTheMiddleOfEnteringNumber;
@synthesize userHasEnteredDecimalPoint = _userHasEnteredDecimalPoint;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (! _brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)updateDisplays
{
    id program = [self.brain program];
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:program];
    NSSet * variableList = [CalculatorBrain variablesUsedInProgram:program];

    NSString * variableDisplayString = @"";
    if (variableList)
    {
        BOOL firstElem = YES;
        for (id elem in variableList)
        {
            if ([elem isKindOfClass:[NSString class]])
            {
                if (!firstElem)
                {
                    variableDisplayString = [variableDisplayString stringByAppendingString:@"  "];
                }
                
                double value = 0.0;
                if (self.testVariableValues)
                {
                    id dictionaryValue = [self.testVariableValues valueForKey:elem];
                    if (dictionaryValue && [dictionaryValue isKindOfClass:[NSNumber class]])
                    {
                        NSNumber * dictionaryNumber = dictionaryValue;
                        value = [dictionaryNumber doubleValue];
                    }
                }
                
                variableDisplayString = [variableDisplayString stringByAppendingFormat:@"%@ = %g", elem, value];
                
                firstElem = NO;
            }
        }
    }
    
    self.variableDisplay.text = variableDisplayString;
}

- (void)pushOperand:(double)operand
{
//    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingFormat:@" %g", operand];
    [self.brain pushOperand:operand];    
    //self.errorDisplay.text = @"";
    [self updateDisplays];
}

- (void)pushVariableOperand:(NSString *)variableName
{
    //    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingFormat:@" %g", operand];
    [self.brain pushVariableOperand:variableName];    
    //self.errorDisplay.text = @"";
    [self updateDisplays];
}

- (id)performOperation:(NSString *)operation
{
//    NSString * errorMsg;
    id result = [self.brain performOperation:operation usingVariableValues:self.testVariableValues];
//    double result = [self.brain performOperation:operation withErrorMessage:&errorMsg];
//    if (errorMsg.length > 0)
//        self.errorDisplay.text = errorMsg;
//    else
//    {
        //self.errorDisplay.text = @"";
//        self.historyDisplay.text = [self.historyDisplay.text stringByAppendingFormat:@" %@ =", operation];
    [self updateDisplays];
//    }

    return result;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringNumber)
    {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }
    else
    {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringNumber = YES;
        self.userHasEnteredDecimalPoint = NO;
    }
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    id result = [self performOperation:operation];
    if ([result isKindOfClass:[NSNumber class]])
    {
        self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    }
    else if ([result isKindOfClass:[NSString class]])
    {
        self.display.text = result;
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    NSString *variableName = [sender currentTitle];
    [self pushVariableOperand:variableName];
    self.display.text = variableName;
}

- (IBAction)enterPressed {
    [self pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringNumber = NO;
    self.userHasEnteredDecimalPoint = NO;
} 

- (IBAction)decimalPointPressed {
    if (self.userIsInTheMiddleOfEnteringNumber)
    {
        if (!self.userHasEnteredDecimalPoint)
        {
            self.display.text = [self.display.text stringByAppendingString:@"."];
            self.userHasEnteredDecimalPoint = YES;
        }
    }
    else
    {
        self.display.text = @"0.";
        self.userIsInTheMiddleOfEnteringNumber = YES;
        self.userHasEnteredDecimalPoint = YES;
    }
}

- (IBAction)clearPressed {
    [self.brain performClear];
    self.display.text = @"0";
    self.historyDisplay.text = @"";
    self.variableDisplay.text = @"";
    self.userIsInTheMiddleOfEnteringNumber = NO;
    self.userHasEnteredDecimalPoint = NO;
}

- (IBAction)backspacePressed {
    NSString * currentText = self.display.text;
    if (self.userIsInTheMiddleOfEnteringNumber &&
        currentText.length > 0)
    {
        self.display.text =
          [currentText substringToIndex:currentText.length-1];
        if (self.display.text.length < 1) self.display.text = @"0";
    }
}

- (IBAction)signTogglePressed {
    if (self.userIsInTheMiddleOfEnteringNumber)
    {
        // sign toggle the current number
        NSString * currentText = self.display.text;
        if ([currentText hasPrefix:@"-"])
        {
            self.display.text = [currentText substringFromIndex:1];
        }
        else
        {
            self.display.text = [@"-" stringByAppendingString:currentText];
        }
    }
    else
    {
        // single operand operation
        id result = [self performOperation:@"+/-"];
        if ([result isKindOfClass:[NSNumber class]])
        {
            self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
        }
        else if ([result isKindOfClass:[NSString class]])
        {
            self.display.text = result;
        }
    }
}

- (IBAction)updateTestVariableList:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    NSString *buttonText = [sender currentTitle];
    if ([buttonText isEqualToString:@"Test1"])
    {
        self.testVariableValues = nil;
    }
    else if ([buttonText isEqualToString:@"Test2"])
    {
        self.testVariableValues = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:2], @"x", [NSNumber numberWithDouble:3], @"y", nil ];
    }
    else if ([buttonText isEqualToString:@"Test3"])
    {
        self.testVariableValues = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:1], @"x", [NSNumber numberWithDouble:2.5], @"y", [NSNumber numberWithDouble:3.75], @"foo", nil ];
    }
    id program = [self.brain program];
    id result = [[[self brain] class] runProgram:program usingVariableValues:[self testVariableValues]];
    if ([result isKindOfClass:[NSNumber class]])
    {
        self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    }
    else if ([result isKindOfClass:[NSString class]])
    {
        self.display.text = result;
    }
    [self updateDisplays];
}

- (IBAction)undoPressed {
    if (self.userIsInTheMiddleOfEnteringNumber)
    {
        if (self.display.text.length > 1)
        {
            self.display.text = [self.display.text substringToIndex:self.display.text.length - 1];
        }
        else
        {
            self.userIsInTheMiddleOfEnteringNumber = NO;
            // will clear display by running program
        }
    }
    else
    {
        [self.brain removeTopOfStack];
    }
    
    if (!self.userIsInTheMiddleOfEnteringNumber)
    {
        id program = [self.brain program];
        id result = [[[self brain] class] runProgram:program usingVariableValues:[self testVariableValues]];
        if ([result isKindOfClass:[NSNumber class]])
        {
            self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
        }
        else if ([result isKindOfClass:[NSString class]])
        {
            self.display.text = result;
        }
        [self updateDisplays];
    }
}

- (void)viewDidUnload {
    [self setDisplay:nil];
    [self setHistoryDisplay:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}
@end
