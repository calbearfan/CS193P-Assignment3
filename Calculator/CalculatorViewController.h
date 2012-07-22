//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Mike Dunker on 6/22/12.
//  Copyright (c) 2012 Dunker Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *historyDisplay;
@property (weak, nonatomic) IBOutlet UILabel *variableDisplay;

@end
