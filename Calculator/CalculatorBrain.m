//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Mike Dunker on 6/23/12.
//  Copyright (c) 2012 Dunker Development. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain
@synthesize operandStack = _operandStack;

- (NSMutableArray *)operandStack
{
    if (!_operandStack) _operandStack = [[NSMutableArray alloc] init];
    return _operandStack;
}

- (void)pushOperand:(double)operand
{
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)peekOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    return [operandObject doubleValue];
}

- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    return [operandObject doubleValue];
}

- (double)performOperation:(NSString *)operation
           withErrorMessage:(NSString **)pErrMsg
{
    double result = 0;
    BOOL valid = YES;
    
    if ([operation isEqualToString:@"+"])
    {
        result = [self popOperand] + [self popOperand];
    }
    else if ([operation isEqualToString:@"-"])
    {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
    }
    else if ([operation isEqualToString:@"*"])
    {
        result = [self popOperand] * [self popOperand];
    }
    else if ([operation isEqualToString:@"/"])
    {
        double divisor = [self peekOperand];
        if (divisor)
        {
            [self popOperand];
            result = [self popOperand] / divisor;
        }
        else
        {
            valid = NO;
            if (pErrMsg) *pErrMsg = @"Cannot divide by zero.";
        }
    }
    else if ([operation isEqualToString:@"sin"])
    {
        result = sin([self popOperand]);
    }
    else if ([operation isEqualToString:@"cos"])
    {
        result = cos([self popOperand]);
    }
    else if ([operation isEqualToString:@"sqrt"])
    {
        double operand = [self peekOperand];
        if (operand >= 0)
            result = sqrt([self popOperand]);
        else
        {
            valid = NO;
            if (pErrMsg) *pErrMsg = @"Cannot take sqrt of negative number.";
        }
    }
    else if ([operation isEqualToString:@"π"])
    {
        result = M_PI;
    }
    else if ([operation isEqualToString:@"+/-"])
    {
        result = 0 - [self popOperand];
    }
    
    if (valid)
    {
        [self pushOperand:result];
        return result;
    }
    else
    {
        return [self peekOperand];
    }
}

- (void)performClear
{
    [self.operandStack removeAllObjects];
}

@end
