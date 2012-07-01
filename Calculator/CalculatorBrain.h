//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Mike Dunker on 6/23/12.
//  Copyright (c) 2012 Dunker Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation withErrorMessage:(NSString **)pErrMsg;
- (void)performClear;

@end
