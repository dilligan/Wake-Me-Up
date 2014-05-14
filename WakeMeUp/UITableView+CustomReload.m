//
//  UITableView+CustomReload.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 5/9/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "UITableView+CustomReload.h"

@implementation UITableView (CustomReload)

-(void)reloadData:(BOOL)animated {
    [self reloadData];
    
    if (animated) {
        [self setHidden:NO];
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:.3];
        [[self layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    }
    
    
    
}



@end
