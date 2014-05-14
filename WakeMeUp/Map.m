//
//  Map.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/19/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "Map.h"
#import <MapKit/MapKit.h>
@interface Map ()
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation Map
@synthesize stopData, mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];    
    double lat = [[stopData objectForKey:@"Lat"] doubleValue];
    double lon = [[stopData objectForKey:@"Lon"] doubleValue];
    CLLocationCoordinate2D stopC = CLLocationCoordinate2DMake(lat, lon);
    
    mapView.region = MKCoordinateRegionMake(stopC, MKCoordinateSpanMake(0.01, 0.01));
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = stopC;
    annotation.title = [stopData objectForKey:@"Name"];
    [mapView addAnnotation:annotation];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
