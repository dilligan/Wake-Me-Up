//
//  StopChooser.h
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/18/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopChooser : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *stopLabel;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UILabel *stepperLabel;
- (IBAction)stepperChange:(id)sender;

- (IBAction)done:(id)sender;

@end
