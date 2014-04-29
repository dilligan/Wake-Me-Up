//
//  ViewController.h
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/18/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *locationField;
- (IBAction)wakeMeUp:(id)sender;
- (IBAction)vibrateSwitched:(id)sender;
- (IBAction)soundSwitched:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *vibrateLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *vibrateTime;
@property (strong, nonatomic) IBOutlet UISegmentedControl *songSegment;
@property (strong, nonatomic) IBOutlet UITextField *songTextField;
@property (strong, nonatomic) IBOutlet UIView *switchBack;
- (IBAction)vibSwitchChanged:(id)sender;

-(void)startStandardUpdates;
-(void)stopTimer;
@end
