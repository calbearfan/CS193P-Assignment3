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

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
@end

@implementation CalculatorViewController

@synthesize display;
@synthesize historyDisplay;
@synthesize errorDisplay;
@synthesize userIsInTheMiddleOfEnteringNumber;
@synthesize userHasEnteredDecimalPoint;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (! _brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)pushOperand:(double)operand
{
    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingFormat:@" %g", operand];
    [self.brain pushOperand:operand];    
    self.errorDisplay.text = @"";
}

- (double)performOperation:(NSString *)operation
{
//    NSString * errorMsg;
    double result = [self.brain performOperation:operation];
//    double result = [self.brain performOperation:operation withErrorMessage:&errorMsg];
//    if (errorMsg.length > 0)
//        self.errorDisplay.text = errorMsg;
//    else
//    {
        self.errorDisplay.text = @"";
        self.historyDisplay.text = [self.historyDisplay.text stringByAppendingFormat:@" %@ =", operation];
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
    double result = [self performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
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
    self.errorDisplay.text = @"";
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
        double result = [self performOperation:@"+/-"];
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
}

- (void)viewDidUnload {
    [self setHistoryDisplay:nil];
    [self setErrorDisplay:nil];
    [super viewDidUnload];
}
@end
