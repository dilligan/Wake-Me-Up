//
//  Map.h
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/19/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Map : UIViewController
@property (nonatomic, strong) NSDictionary *stopData;
@property (nonatomic, strong) NSArray *polylines;
@property (nonatomic) BOOL isStop;

-(void)traceRoute;

@end
