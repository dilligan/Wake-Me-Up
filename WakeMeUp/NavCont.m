//
//  NavCont.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/19/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "NavCont.h"

@interface NavCont ()

@end

@implementation NavCont


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    
}

-(BOOL)shouldAutorotate {
    return NO;
}
@end
